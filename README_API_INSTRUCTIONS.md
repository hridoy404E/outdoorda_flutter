## API Integration Notes for AI Agents

This document is for any AI assistant (Codex) working on new network-backed features within `outdoorda_flutter`. Follow these rules when implementing or refactoring any API call.

1. **Always go through `NetworkCaller`.**
   - All requests must use `lib/core/services/network_caller.dart`.
   
   - Do not invoke `http`/`dio` directly elsewhere.

2. **Centralize URLs in `ApiEndpoints`.**
   - Import `package:outdoorda_flutter/core/utils/constants/api_endpoints.dart`.
   - Use `ApiEndpoints.baseUrl` or the specific endpoint constants (`login`, `refreshToken`, `logout`, etc.).
   - If a new endpoint is needed, add it to this file before referencing it.

3. **Create a dedicated API controller/service.**
   - Keep UI controllers (e.g., GetxControllers) lean: delegate HTTP orchestration to a service or API controller class.
   - The service should accept input DTOs, call `NetworkCaller`, detect success/failure, and return sanitized data to the UI controller.
  
   - Catch/handle errors inside the service and leave UI-level error display to calling controllers.

4. **Log responses for debugging.**
   - Use `AppLoggerHelper` (from `core/utils/logging/logger.dart`) to log request/response payloads only inside services/controllers responsible for API calls.
   - Log incoming response strings, HTTP status, and any parsed message so debugging is easier.

5. **Maintain clean controller code.**
   - Avoid inline dialogs/network logic inside UI controllers; keep them focused on validation, state, and navigation.
   - Use helper methods or widgets (e.g., `OtpDialog`) for reusable UI pieces.
   - Remove hard-coded strings/URLs: route through central constants or strings.

When you follow the above pattern, future API work remains consistent and debuggable for both humans and AI helpers.
