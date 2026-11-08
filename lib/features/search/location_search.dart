import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_weather_demo/data/models/location.dart';
import 'package:flutter_weather_demo/domain/location_label.dart';
import 'package:flutter_weather_demo/l10n/error_messages.dart';
import 'package:flutter_weather_demo/l10n/messages.dart';
import 'package:flutter_weather_demo/state/app_state.dart';
import 'package:flutter_weather_demo/state/providers.dart';

class LocationSearch extends ConsumerStatefulWidget {
  const LocationSearch({
    super.key,
    required this.onSelect,
    this.onOpenChange,
  });

  final ValueChanged<SelectedLocation> onSelect;
  final ValueChanged<bool>? onOpenChange;

  @override
  ConsumerState<LocationSearch> createState() => LocationSearchState();
}

class LocationSearchState extends ConsumerState<LocationSearch> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  final _fieldKey = GlobalKey();
  OverlayEntry? _overlay;
  Timer? _debounce;
  String _debounced = '';
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(() {
      setState(() {});
      _overlay?.markNeedsBuild();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void dismiss() {
    _focusNode.unfocus();
    _setOpen(false);
  }

  void _setOpen(bool open) {
    if (_open == open) return;
    setState(() => _open = open);
    widget.onOpenChange?.call(open);
    if (open) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onFocusChange() {
    _setOpen(_focusNode.hasFocus);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _debounced = value.trim());
      _overlay?.markNeedsBuild();
    });
  }

  int _minQueryLength(String locale) => locale == 'zh' ? 1 : 2;

  void _showOverlay() {
    if (_overlay != null) return;
    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(builder: _buildOverlay);
    overlay.insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  Widget _buildOverlay(BuildContext context) {
    final app = ref.read(appControllerProvider);
    final locale = app.locale;
    final minLen = _minQueryLength(locale);
    final query = _debounced;
    final canSearch = query.length >= minLen;
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? MediaQuery.sizeOf(context).width - 32;

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: dismiss,
            child: const SizedBox.expand(),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 56),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: width,
                child: Material(
                  color: const Color(0xEB0F172A),
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: canSearch
                        ? Consumer(
                            builder: (context, ref, _) {
                              final asyncResults = ref.watch(
                                geocodeProvider(GeocodeQuery(query, locale)),
                              );
                              return _buildDropdown(
                                locale: locale,
                                canSearch: true,
                                queryEmpty: false,
                                asyncResults: asyncResults,
                                recent: app.recent,
                              );
                            },
                          )
                        : _buildDropdown(
                            locale: locale,
                            canSearch: false,
                            queryEmpty: query.isEmpty,
                            asyncResults: null,
                            recent: app.recent,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appControllerProvider.select((s) => s.locale));

    ref.listen(appControllerProvider, (prev, next) {
      if (prev?.recent != next.recent || prev?.locale != next.locale) {
        _overlay?.markNeedsBuild();
      }
    });

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        key: _fieldKey,
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: t(locale, 'searchPlaceholder'),
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _debounced = '');
                    _overlay?.markNeedsBuild();
                  },
                ),
        ),
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildDropdown({
    required String locale,
    required bool canSearch,
    required bool queryEmpty,
    required AsyncValue<GeocodeData>? asyncResults,
    required List<SelectedLocation> recent,
  }) {
    if (queryEmpty) {
      if (recent.isEmpty) {
        return _message(t(locale, 'searchEmpty'));
      }
      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t(locale, 'recent'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(appControllerProvider.notifier)
                        .clearRecent();
                    _overlay?.markNeedsBuild();
                  },
                  child: Text(
                    t(locale, 'clearRecent'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...recent.map((loc) {
            final label = getLocationLabel(loc, locale);
            return ListTile(
              dense: true,
              title: Text(
                formatLocationLabel(label),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: IconButton(
                tooltip: t(locale, 'removeRecent'),
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                onPressed: () async {
                  await ref
                      .read(appControllerProvider.notifier)
                      .removeRecent(loc.id);
                  _overlay?.markNeedsBuild();
                },
              ),
              onTap: () => _select(loc),
            );
          }),
        ],
      );
    }

    if (!canSearch) {
      return _message(t(locale, 'searchEmpty'));
    }

    return asyncResults!.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white70,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (error, _) => _message(getErrorMessage(error, locale)),
      data: (data) {
        if (data.results.isEmpty) {
          return _message(t(locale, 'searchNoResults'));
        }
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: data.results.length,
          itemBuilder: (context, index) {
            final loc = data.results[index];
            final label = LocationLabel(
              name: loc.name,
              country: loc.country,
              admin1: loc.admin1,
            );
            return ListTile(
              dense: true,
              title: Text(
                formatLocationLabel(label),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () => _select(loc),
            );
          },
        );
      },
    );
  }

  Widget _message(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
      ),
    );
  }

  Future<void> _select(SelectedLocation location) async {
    await ref.read(appControllerProvider.notifier).addRecent(location);
    dismiss();
    _controller.clear();
    setState(() => _debounced = '');
    widget.onSelect(location);
  }
}
