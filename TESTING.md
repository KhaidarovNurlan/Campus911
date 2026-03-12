# Testing Documentation: Campus911

This document outlines the testing strategy, scenarios covered, and instructions for running tests within the Campus911 Flutter project.

## 1. How to Run Tests Locally

### Prerequisites

* Flutter SDK installed.
* All dependencies fetched via `flutter pub get`.

### Execution Commands

You can run tests using the following terminal commands:

```bash
flutter test
```

---

## 2. Test Scenarios Covered

The testing suite is divided into three levels to ensure robustness across the application:

### A. Unit Testing (Logic Validation)

**File:** `test/utils/validator_test.dart`

Focuses on the `Validator` utility class to ensure that user input is correctly processed before reaching the server.

* **Scenario:** Email input validation (empty values, incorrect formats, and valid emails).

### B. Integration Testing (Provider & Service Communication)

**File:** `test/data/integration_test.dart`

Tests the interaction between the Business Logic (Providers) and the Data Layer (Firebase Services) using **Mocks**.

* **Scenario 1:** User Registration Flow. Validates that the UI state (`isLoading`) and local user data update correctly after a successful service call.
* **Scenario 2:** Role Conflict Handling. Ensures the system prevents a user from registering as a "Headman" if the role is already occupied in a specific group.
* **Scenario 3:** Note Management. Verifies that `NotesProvider` correctly triggers service calls to fetch and save data, maintaining an up-to-date local list.

### C. Widget Testing (UI & User Interaction)

**File:** `test/pages/register_test.dart`

Simulates user behavior on the Registration screen to verify the interface responds correctly.

* **Scenario 1:** Visual feedback on empty form submission (Validation errors).
* **Scenario 2:** Dynamic UI updates (Selecting a college updates the available groups list).
* **Scenario 3:** Role selection mechanism (Tapping on role cards).

---

## 3. Test Data & Mocking Strategy

To ensure tests are fast and independent of the internet or real Firebase costs, we use **Mocking**.

### Mocks and Fakes

* **Mocktail Library:** Used to create a `MockFirebaseService`. This replaces the real Firebase interaction with "canned" responses.
* **Fallback Values:** A dummy `NoteModel` is registered using `registerFallbackValue` to allow Mocktail to handle custom objects during verification.

### Mock Data used:

| Data Type | Example Values used in Tests |
| --- | --- |
| **Users** | `email: test@mail.com`, `name: Surname Name`, `role: student/headman` |
| **Colleges** | `AITU`, `KILC` |
| **Groups** | `ПО2303`, `K-1` |
| **Notes** | `title: New Integration Note`, `content: Clean Code` |

### Requirements for Running

No real Firebase accounts or `.env` files are required for these tests as all external service calls are intercepted by the `MockFirebaseService`.

---

## 4. Full List of Tests

**Unit Tests:**

1. `Empty email returns error`
2. `Incorrect email returns error`
3. `Valid email returns null`
4. `Null value returns error`

**Integration Tests:**

5. `Successful registration updates user data and loading state`
6. `Registration fails if headman is already taken`
7. `NotesProvider integration: loading and adding notes`

**UI Tests:**

8. `Should show validation errors when fields are empty`
9. `Changing college should update groups list`
10. `Tapping Headman card should select it`
