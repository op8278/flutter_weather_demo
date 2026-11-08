# Weather App (Flutter)

A small Flutter weather demo (iOS-first): search places, save cities, and view forecasts. Migrated from the Next.js app [next-weather-demo](https://github.com/op8278/next-weather-demo); the mobile client calls that project’s production APIs (no API keys).

中文说明见 [README.zh-CN.md](./README.zh-CN.md)。

## Related demos

- Web / API repo: [https://github.com/op8278/next-weather-demo](https://github.com/op8278/next-weather-demo)
- React Native repo: [https://github.com/op8278/rn-weather-demo](https://github.com/op8278/rn-weather-demo)
- Live API / web: [https://next-weather-demo.vercel.app/](https://next-weather-demo.vercel.app/)

## Features

- Favorites city list (iOS Weather–style cards)
- Weather detail with hourly + 7-day forecast
- WMO weather icons next to condition text (current, hourly, daily, city cards)
- Hourly forecast: list / temperature-curve tabs for the current day
- 7-day forecast: tap a day to open a bottom sheet with that day’s temperature curve
- Localized city labels (`zh` / `en`) resolved by Open-Meteo location id (not fuzzy name search)
- Global refresh on list and detail (left of the language switcher), with per-card / detail loading UI
- Add / remove cities from the list (persisted in SharedPreferences)
- Location search with overlay dropdown (does not push the list layout)
- Loading / error / retry states
- Simplified Chinese and English (local dictionaries)

## Screens

| Route | Purpose |
| --- | --- |
| `/` | Saved cities list + search |
| `/weather/:id?lat=&lon=&name=` | Weather detail for a city |

Flow:

1. Open `/` to see favorited cities (starts empty).
2. Search a city → opens detail (does **not** auto-favorite).
3. Tap ★ on detail to add/remove from the list.
4. On the list, swipe a card left to delete.
5. Use the refresh button to re-fetch weather; list cards and the detail page show loading while updating.

## Tech stack

| Layer | Choice | Why |
| --- | --- | --- |
| Framework | Flutter + Material 3 | Single codebase; iOS Simulator first |
| Navigation | `go_router` | Path + query params aligned with web/RN routes |
| State | `flutter_riverpod` + SharedPreferences | Favorites, locale, recent; weather/geocode providers |
| HTTP | `http` | Thin client around the Vercel `{ code, data, msg }` envelope |
| Upstream weather | Open-Meteo (via Next.js API) | Free, no API key; same contract as the web demo |
| Remote API | `https://next-weather-demo.vercel.app/api/*` | Reuse deployed Route Handlers; no local BFF |

### Design trade-offs

- **Riverpod vs store**: Providers own remote weather/geocode cache (≈5 min keepAlive). `AppController` owns favorites and locale. Detail screens are driven by the route, not a single global “current city”.
- **Consume Vercel API, don’t re-implement Open-Meteo**: Keeps Zod / IPv4 proxy / response shaping on the server; the app only needs `ApiClient` + `--dart-define=API_BASE`.
- **No API key**: Same as the web demo.
- **Local i18n only**: `zh` / `en` strings live in the repo; call `initializeDateFormatting` for weekday labels.
- **Label resolve by id**: Locale switches look up `/api/geocode?id=` so city names stay exact across languages.
- **Simulator + proxy**: iOS Simulator does not use macOS system proxy. If Vercel is unreachable from the sim, run the RN project’s local `api-proxy` (see below).

## API contract

Default base URL: `https://next-weather-demo.vercel.app`

All APIs return:

```json
{
  "code": 0,
  "data": {},
  "msg": "ok"
}
```

| `code` | Meaning |
| --- | --- |
| `0` | Success |
| `40001` | Invalid params |
| `40401` | Location not found |
| `50201` | Upstream Open-Meteo failed |
| `50000` | Unknown / network / parse error |

Endpoints:

- `GET /api/geocode?q=taipei&lang=en|zh` — search by name
- `GET /api/geocode?id=1796236&lang=zh` — exact lookup by location id
- `GET /api/weather?lat=25.05&lon=121.53&name=Taipei`

The client throws `ApiError` when `code !== 0` (HTTP status is ignored). UI maps codes to localized messages.

### Override base URL

```bash
flutter run --dart-define=API_BASE=https://next-weather-demo.vercel.app
```

### iOS Simulator + proxy

The iOS Simulator does not use the macOS system proxy. If Vercel times out from the sim, reuse the RN project’s reverse proxy:

```bash
# Terminal 1 — in rn-weather-demo
HTTPS_PROXY=http://127.0.0.1:7890 npm run api-proxy

# Terminal 2 — use the printed LAN URL
flutter run -d ios --dart-define=API_BASE=http://192.168.x.x:8787
```

`Info.plist` enables `NSAllowsLocalNetworking` so HTTP to the LAN proxy is allowed.

## Project structure

```text
lib/
  app/router.dart         go_router routes
  core/api/               ApiClient + error codes
  core/config.dart        API_BASE via --dart-define
  data/                   models + geocode/weather APIs
  domain/                 WMO map, hourly windows, location labels
  l10n/                   en / zh strings
  state/                  Riverpod app store + providers
  features/cities/        Favorites list UI
  features/search/        Location search overlay
  features/weather/       Detail panels, curve, sheet, icons
  features/common/        Locale switcher, refresh, loading/error
```

Persistence (SharedPreferences key `weather-app-store`): `locale`, `favorites`, `recent`.

## Getting started

```bash
flutter pub get
flutter run -d ios
```

## Verify

```bash
flutter analyze
flutter test
```
