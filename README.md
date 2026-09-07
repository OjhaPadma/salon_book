# GlamSlot

A Flutter salon appointment booking app built as a portfolio project. Clients discover salons, book real time slots with conflict-safe availability, and manage appointments. Staff get a live day calendar to mark visits complete or no-show.

**Tagline:** Find a quiet chair.

## Features

### Client
- **Discover** — search salons by name, service, or stylist; filter by category and rating
- **Salon profiles** — services, stylists, gallery, and reviews
- **Booking flow** — pick stylist (or any available), choose date/time from live availability, confirm
- **Appointments** — upcoming/past tabs, reschedule, cancel with 24h policy, post-visit reviews
- **Notifications** — confirmation plus 24h and 1h reminders (mobile; no-op on web)
- **Guest browsing** — explore and book without signing in

### Staff
- **Role-gated dashboard** — day calendar by stylist with live booking updates
- **Visit management** — mark appointments complete or no-show from a booking sheet

### Engineering highlights
- **Availability engine** — working hours, service duration, 15-minute buffer, stylist conflicts, "any available" fallback
- **Feature-first architecture** — `core` / `domain` / `data` / `features`
- **Repository pattern** with in-memory seed data (swap for a real backend later)
- **Role-based routing** — clients and staff see different shells

## Demo accounts

| Role   | Email                  | Password |
|--------|------------------------|----------|
| Client | `client@glamslot.com`  | `client` |
| Staff  | `staff@glamslot.com`   | `staff`  |

Staff is linked to **Atelier Noor** (`salon-noor`). Sign in from Profile, or use the demo chips on the login screen.

## Getting started

### Prerequisites
- [Flutter](https://docs.flutter.dev/get-started/install) 3.12+ (Dart 3.12+)

### Run locally

```bash
git clone https://github.com/OjhaPadma/salon_book.git
cd salon_book
flutter pub get
flutter run
```

### Tests & analysis

```bash
flutter analyze
flutter test
```

## Project structure

```
lib/
├── core/           Theme, routing, DI, notifications, shared widgets
├── domain/         Models and repository interfaces
├── data/           Seed data and in-memory implementations
└── features/
    ├── auth/       Demo auth, login, role redirects
    ├── discovery/  Search, filters, salon profiles
    ├── booking/    Availability engine, booking flow
    ├── appointments/  Bookings list, detail, cancellation policy
    ├── staff/      Staff dashboard and day calendar
    └── profile/    Account and sign-in/out
```

## Tech stack

| Area        | Package / approach        |
|-------------|---------------------------|
| State       | `flutter_bloc`, `ChangeNotifier` (auth) |
| Routing     | `go_router` with auth redirects |
| DI          | `get_it`                  |
| Calendar    | `table_calendar`          |
| Typography  | `google_fonts` (Fraunces + Outfit) |
| Notifications | `flutter_local_notifications` |

## Seeded salons

Four Bengaluru salons ship with demo data:

- Atelier Noor
- Bloom & Blade
- The Quiet Chair
- Maison Pearl

## Dual-perspective demo

1. Sign in as **staff** → open the dashboard for Atelier Noor
2. In another session (or as guest/client), book at Atelier Noor
3. Staff dashboard updates live; tap a block to mark complete or no-show
4. Client **Past** tab shows completed visits; reviews unlock only after completion

## License

This project is for portfolio and learning purposes.
