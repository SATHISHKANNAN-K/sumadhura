Sumuthra Visitor Management Mobile Application
Project Introduction
Hello, and thank you for reviewing my project.

I developed this Visitor Management Mobile Application using Flutter and Dart to help front-desk and security staff manage visitor registrations and track visits at residential projects. The application allows staff to register visitors, view and update their information, generate visitor QR passes, scan QR codes to identify visitors, and record check-in and check-out activities.

For this project, I used BLoC for state management, go_router for navigations, a REST API for visitor records, qr_flutter to generate QR codes, and mobile_scanner to scan them. I chose a simple, consistent design with #C39A3E as the primary color.
Main Features

- Dashboard: Displays the number of visitors registered today, visitors currently checked in, and visitors checked out today.
- Visitor registration: Allows staff to enter a visitor's name, mobile number, optional email, visitor type, project, and purpose of visit.
- Visitor list and search: Displays visitor records and supports searching by name, mobile number, project, or status.
- Visitor management: Supports viewing details, editing visitor information, and deleting a record after confirmation.
- QR visitor pass: Generates a QR code containing the visitor ID returned by the API.
- QR scanning: Opens the device camera to scan a visitor pass and look up the visitor record.
- Check-in and check-out: Follows the status flow Registered → Checked In → Checked Out and records timestamps.
- Feedback and error handling: Shows loading indicators and messages for API errors and user actions.
  How I Organized the Code
  I separated the application into models, API/data handling, state management, screens, and shared styling so that each part has a clear responsibility.
- lib/models/visitor.dart — Defines the visitor model and handles JSON conversion.
- lib/data/visitor_api.dart — Sends HTTP requests to the REST API and handles unsuccessful responses.
- lib/data/visitor_repository.dart — Provides the data layer and applies the check-in/check-out rules.
- lib/logic/visitor_bloc.dart — Defines BLoC events and states, loads and updates visitor records, and calculates dashboard statistics.
- lib/ui/ — Contains the dashboard, visitor list, registration form, visitor details, QR scanner, and reusable widgets.
- lib/core/app_theme.dart — Defines the shared Material 3 theme and the gold primary color.
  Why I Used BLoC
  I used BLoC to keep business logic separate from the UI. Screens send events—for example, requesting visitors, saving a visitor, or checking a visitor in—and the BLoC manages the asynchronous work and emits states for the UI to display.

Keeping visitor data in a shared BLoC helps the dashboard and visitor list reflect changes after API operations. It also gives the application a consistent place to handle loading and error states.
Visitor Status Workflow
Each registration supports one visit session, as required by the assignment:

1. A newly registered visitor starts with the status Registered.
2. Staff can check in a visitor whose status is Registered. The app records the check-in time and changes the status to Checked In.
3. Staff can check out a visitor whose status is Checked In. The app records the check-out time and changes the status to Checked Out.
4. A visitor who has checked out cannot be checked in again under the same registration.
   The QR code uses the visitor ID returned by the API, so scanning the code can be used to retrieve that visitor's details.
   REST API
   The application uses a REST API to store visitor records. A persistent mock service such as MockAPI can be used; a separate backend application is not required for this assignment.

The API base URL is configurable through the VISITOR_API_BASE_URL Dart environment define. The configured URL should point to the API base path and should not end with /visitors.

The app expects the following endpoints:
Method Endpoint Purpose
GET /visitors Retrieve visitor records
GET /visitors/{id} Retrieve a visitor by ID
POST /visitors Register a visitor and receive the server-generated ID
PUT /visitors/{id} Update visitor details or visit status
DELETE /visitors/{id} Delete a visitor record

The visitor record includes the name, mobile number, email, visitor type, project, purpose, status, registration timestamp, check-in timestamp, and check-out timestamp.
Setup and Run
Requirements

- Flutter stable with Dart 3.3 or newer.
- Android Studio and Android SDK.
- A configured MockAPI project or another compatible REST API.

1. Generate Android platform files
   The source archive contains the Dart application code and configuration. If the Android platform folder is not present, run this command from the project root:
   flutter create --platforms=android .
2. Configure camera permission
   Open android/app/src/main/AndroidManifest.xml and add the following line above the <application> element:
   <uses-permission android:name="android.permission.CAMERA" />
3. Configure the API
   Create a visitors resource in MockAPI and copy the API base URL. For example, use:
   https://6ae03e448e42963c8d5f305b.mockapi.io/api/v1
   Replace the example URL with your actual service URL.
4. Install packages and run
   flutter pub get
   flutter run --dart-define=VISITOR_API_BASE_URL=https://6ae03e448e42963c8d5f305b.mockapi.io/api/v1
5. Build the Android APK
   After configuring the API and testing the application, build a release APK with:
   flutter build apk --release --dart-define=VISITOR_API_BASE_URL=https://6ae03e448e42963c8d5f305b.mockapi.io/api/v1
   The API must remain accessible when the application is evaluated. The source archive does not include a compiled APK or a preconfigured live API URL.
   Validation and Testing
   Before demonstrating the application, I would verify the following workflows:

- Register a visitor with valid information and confirm that the API returns an ID.
- Confirm that missing required fields, an invalid mobile number, and an invalid entered email display validation messages.
- Edit a visitor and check that the changes remain after refreshing the list.
- Search for visitors by name or mobile number.
- Confirm that deletion requires user confirmation.
- Generate a QR code, scan it, and open the corresponding visitor details.
- Check that invalid or unknown QR codes show an error message.
- Confirm that a visitor cannot check in twice or check out before checking in.
- Confirm that a completed visit cannot be checked in again.
- Verify that dashboard statistics reflect updated visitor records.
- Test API failure handling and camera permission behavior on an Android device.
  Notes
- Dashboard date-based metrics use the device's local date.
- One visit session per visitor registration is supported; repeat-visit history is outside the assignment scope.
- Visitor records require a working, configured REST API. The app does not use a hard-coded local list as a substitute for persistent API storage.
- Before submission, the project should be run and tested with a real mock API, and the release APK should be built from that tested configuration.
