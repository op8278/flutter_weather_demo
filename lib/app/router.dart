import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_weather_demo/domain/location_label.dart';
import 'package:flutter_weather_demo/features/cities/city_list_page.dart';
import 'package:flutter_weather_demo/features/weather/weather_detail_page.dart';
import 'package:flutter_weather_demo/state/app_state.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CityListPage(),
      ),
      GoRoute(
        path: '/weather/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _RedirectHome();
          }

          final app = ref.read(appControllerProvider);
          final location = app.favoriteById(id) ??
              parseLocationFromQuery(
                id: id,
                query: state.uri.queryParameters,
              );

          if (location == null) {
            return const _RedirectHome();
          }

          return WeatherDetailPage(location: location);
        },
      ),
    ],
  );
});

class _RedirectHome extends StatefulWidget {
  const _RedirectHome();

  @override
  State<_RedirectHome> createState() => _RedirectHomeState();
}

class _RedirectHomeState extends State<_RedirectHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF10141c),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white70),
      ),
    );
  }
}
