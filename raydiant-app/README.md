# Raydiant

**Your UV, for you.**

Started in May 2025, after a friend and I kept going back and forth trying to figure out when to actually go tan. We'd check a weather app for UV numbers, guess at timing, and still end up either burning or missing the window entirely. There wasn't anything that turned "the UV index is 7 right now" into an actual answer to "so when should I go outside." So I built one.

Raydiant is a SwiftUI iOS app that turns UV index, weather, and location data into a personalized daily "glow" score, tan windows, sunscreen reminders, and beauty-condition forecasts (makeup survival, hair frizz, sweatiness). It's a native app, not a website. See "Running it" below for what that means.

## How it's actually used, day to day

Open the app in the morning and the Today tab leads with a glow score out of 100, built from live UV, cloud cover, humidity, and temperature, not just a raw UV number. Underneath it, a graph of the day's UV curve and a plain-language read on when it's actually worth going outside.

From there:

- **Deciding when to tan** — the app calculates a best tan window for the day (avoiding the dangerous midday spike, favoring morning or late-afternoon UV that's still strong enough to work), plus a lower-risk window for anyone who wants a gentler exposure, and a golden-hour window for photos.
- **Not getting burned** — a burn-risk estimate factors in skin tone and burn tendency from onboarding, so the "you'll likely start burning in X minutes" number is personal, not generic.
- **Remembering to reapply SPF** — a running timer starts the moment you tap "I applied SPF," counts down based on current UV, and fires a local notification when it's time to reapply. This was the actual daily annoyance that started the whole project: forgetting to reapply and burning anyway despite having sunscreen on.
- **Planning around the rest of the day** — beyond just tanning, it also estimates how humidity and heat will affect makeup, hair frizz, and general sweatiness, and scores whether today is a good beach day at all.
- **Planning ahead** — the Forecast tab gives the same breakdown 14 days out, so a beach trip or outdoor event can be planned around the best UV day, not just whichever day was free.
- **Tan Plan** — pick a specific goal (tan, lower-risk tan, outdoor photos, avoid burning, beach day) and it turns the day's data into one concrete answer: best time, what to bring, and how much SPF.

## What's in the app

Five tabs:

- **Today** current glow score, UV graph, tan windows, a sunscreen reapply timer, and expandable cards for burn risk, hyperpigmentation, makeup survival, hair frizz, sweatiness, and beach day score
- **Forecast** 14 day outlook with a detail view per day
- **Tan Plan** pick a goal (tan, lower risk, photos, avoid burn, beach day) and get a tailored time window and packing list
- **Friends** local MVP/mock social layer, structured to plug in a real backend later
- **Profile** skin tone, burn tendency, tanning experience, beauty concerns, default city, and app settings

Onboarding walks through goal, skin profile, tanning experience, beauty concerns, and location before landing in the app.

## Project structure

```
App/
  RaydiantApp.swift        entry point, decides onboarding vs main app
  ContentView.swift        the five tab shell

Views/
  OnboardingView.swift
  TodayView.swift
  ForecastView.swift
  TanPlanView.swift
  FriendsView.swift
  ProfileView.swift

Components/
  GlassCard.swift
  ScoreRing.swift
  TimerCard.swift
  UVGraphView.swift
  RiskPill.swift
  GradientBackground.swift
  ForecastDayCard.swift
  RaydiantLogoView.swift
  ShareCardView.swift
  OnboardingOptionButton.swift

Calculators/
  GlowScoreCalculator.swift
  BurnRiskCalculator.swift
  SunscreenCalculator.swift
  TanWindowCalculator.swift
  BeautyIndexCalculator.swift

Services/
  AppState.swift            the app's shared state, its view model
  WeatherService.swift      Open-Meteo API calls
  LocationService.swift     Core Location wrapper
  NotificationService.swift local push notifications

Models/
  GlowModels.swift            TimeWindow, GlowLabel, RiskLevel, BurnRisk, DayForecast, TodayGlowData, FriendStatus, TanPlanResult
  WeatherModels.swift         Open-Meteo API response shapes, GeocodingResult
  UserProfile.swift           UserProfile plus its enums (Goal, SkinTone, BurnTendency, TanningExperience, BeautyConcern)

Constants.swift
Extensions.swift
MockData.swift               fallback data when the API call fails
```

## Running it

This is a native SwiftUI app, not a web app. To run it you need:

1. A Mac with Xcode installed
2. Create a new iOS App project in Xcode (SwiftUI, Swift)
3. Drag these files into the project, organized into the folder structure above
4. Build and run on the iOS Simulator or a physical device

Viewing the code itself works fine in any browser once this is on GitHub. GitHub renders .swift files with syntax highlighting like any other repo. Actually running the app requires Xcode, not a browser.

## APIs used

- [Open-Meteo](https://open-meteo.com/) UV index, temperature, humidity, cloud cover, sunrise/sunset (no API key required)
- Apple's CoreLocation and CLGeocoder for location and reverse geocoding

## Disclaimer

Raydiant provides estimates, not medical advice. Always seek shade and apply SPF.
