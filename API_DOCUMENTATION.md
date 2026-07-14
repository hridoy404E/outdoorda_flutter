# Outdoorda Flutter Application — Backend API Documentation

This document describes all API endpoints, request payloads, response bodies, and WebSocket events used in the Outdoorda Flutter application. It is designed to help backend developers implement or align the backend service.

---

## 1. General Rules & Conventions

* **Base URL:** `http://187.124.228.249:8000` (configurable)
* **Casing Convention:** **`snake_case`** is used for almost all keys in request payloads and responses. Any exceptions (e.g. legacy/fallback `camelCase` or specific uppercase keys) are explicitly noted.
* **Authentication Header:** Standard Bearer authorization is expected for protected endpoints:
  ```http
  Authorization: Bearer <access_token>
  ```
* **Content Types:**
  * Standard API requests use JSON (`application/json`) or URL-encoded form data (`application/x-www-form-urlencoded`).
  * File uploads (e.g. pet/profile photos or job attachments) use Multipart Form Data (`multipart/form-data`).

---

## 2. Authentication & User Accounts

### 2.1 Send OTP
Initiates an OTP verification sequence (e.g. for registration or password resets).

* **Method:** `POST`
* **Endpoint:** `/auth/send_otp`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** None
* **Request Payload:**
  ```json
  {
    "email": "user@example.com",
    "purpose": "signup" // e.g. "signup", "forgot_password", etc.
  }
  ```
* **Response (Status 200 OK):**
  ```json
  {
    "status": "success",
    "message": "OTP sent successfully"
  }
  ```

### 2.2 Verify OTP
Verifies the OTP sent to the user.

* **Method:** `POST`
* **Endpoint:** `/auth/verify_otp`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** None
* **Request Payload:**
  ```json
  {
    "email": "user@example.com",
    "otp_value": "123456",
    "purpose": "signup"
  }
  ```
* **Response (Status 200 OK):**
  ```json
  {
    "status": "success",
    "session_key": "optional_session_uuid_or_token"
  }
  ```

### 2.3 Sign Up
Registers a new user account.

* **Method:** `POST`
* **Endpoint:** `/auth/signup`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** None
* **Request Payload:**
  ```json
  {
    "name": "John Doe",
    "email": "user@example.com",
    "password": "securepassword123",
    "otp_value": "123456",
    "purpose": "signup"
  }
  ```
* **Response (Status 200 OK):**
  ```json
  {
    "status": "success",
    "message": "Account created successfully"
  }
  ```

### 2.4 Log In
Authenticates a user and returns authorization tokens. Handles optional two-factor authentication (2FA).

* **Method:** `POST`
* **Endpoint:** `/auth/login` (Can optionally append `?otp_value=123456` if 2FA verification is requested)
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** None
* **Request Payload:**
  ```json
  {
    "email": "user@example.com",
    "password": "securepassword123"
  }
  ```
* **Response (2FA/OTP Required - Status 200 OK):**
  * If the user has 2FA enabled, the backend should return a payload containing `"otp required"`.
  ```json
  {
    "details": "otp required",
    "message": "Please enter the OTP sent to your email"
  }
  ```
* **Response (Final Success - Status 200 OK):**
  ```json
  {
    "access_token": "eyJhbGciOi...",
    "refresh_token": "eyJhbGciOi...",
    "token_type": "Bearer",
    "role": "customer" // e.g. "customer", "installer", "admin"
  }
  ```

### 2.5 Verify Token (Token Refresh)
Validates the current session and issues refreshed tokens using a refresh token.

* **Method:** `GET`
* **Endpoint:** `/auth/verify-token`
* **Headers:**
  * `refresh-token`: `<refresh_token_string>`
  * `Authorization`: `Bearer <access_token>`
* **Response (Status 200 OK):**
  ```json
  {
    "new_tokens": {
      "access_token": "eyJhbGciOi...",
      "refresh_token": "eyJhbGciOi...",
      "token_type": "Bearer"
    },
    "role": "customer",
    "id": "user_id_string"
  }
  ```
  *(Note: The client can parse `access_token`, `refresh_token`, `token_type`, `role`, and `id` at the top level or inside `new_tokens`.)*

### 2.6 Forgot Password
Resets the password using a verified OTP session key.

* **Method:** `POST`
* **Endpoint:** `/auth/forgot_password`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** None
* **Request Payload:**
  ```json
  {
    "email": "user@example.com",
    "password": "newsecurepassword123",
    "session_key": "otp_verified_session_key"
  }
  ```
* **Response (Status 200 OK):**
  ```json
  {
    "status": "success",
    "message": "Password reset successfully"
  }
  ```

### 2.7 Reset Password (Authenticated)
Changes the password of the logged-in user.

* **Method:** `POST`
* **Endpoint:** `/auth/reset_password`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "old_password": "currentpassword123",
    "password": "newsecurepassword123"
  }
  ```
* **Response (Status 200 OK):**
  ```json
  {
    "status": "success",
    "message": "Password changed successfully"
  }
  ```

---

## 3. User Profile Management

### 3.1 Fetch Current User Profile
Retrieves detailed information about the authenticated user.

* **Method:** `GET`
* **Endpoint:** `/user/users/me`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  {
    "id": "usr_98234710",
    "email": "user@example.com",
    "phone": "+1234567890",
    "name": "Jane Doe",
    "photo": "https://example.com/uploads/profiles/jane.jpg",
    "role": "customer", // "customer", "installer", "admin"
    "is_active": true,
    "is_staff": false,
    "two_factor_enabled": false,
    "is_suspended": false,
    "total_earnings": 1500.00,
    "payable_commission_amount": 150.00,
    "created_at": "2026-06-01T12:00:00Z",
    "updated_at": "2026-07-02T10:00:00Z"
  }
  ```

### 3.2 Update Current User Profile
Updates the profile details and/or picture of the authenticated user.

* **Method:** `PATCH`
* **Endpoint:** `/user/users/me/update-profile`
* **Content-Type:** `multipart/form-data`
* **Authentication:** Required
* **Request Payload:**
  * **Fields:**
    * `name`: `John Doe` (String)
    * `phone`: `+1987654321` (String, optional)
  * **Files:**
    * `photo`: Binary Image File (optional)
* **Response (Status 200 OK):** Returns the updated `UserProfile` JSON (same schema as `3.1`).

### 3.3 Toggle Two-Factor Authentication (2FA)
Enables or disables 2FA for the current user.

* **Method:** `PATCH`
* **Endpoint:** `/user/users/toggle-two-factor`
* **Authentication:** Required
* **Request Payload:** None (Empty Body)
* **Response (Status 200 OK):**
  ```json
  {
    "two_factor_enabled": true
  }
  ```
  *(Note: Response can also wrap the field inside a nested object: `{"data": {"two_factor_enabled": true}}`)*

### 3.4 Delete Account (Self)
Deletes the authenticated user's account.

* **Method:** `DELETE`
* **Endpoint:** `/user/users/me/delete`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  {
    "status": "success",
    "message": "Account deleted successfully"
  }
  ```

---

## 4. Customer Features & Service Requests

### 4.1 Create Service Request
Submits a new job request by a customer.

* **Method:** `POST`
* **Endpoint:** `/customer/posts/`
* **Content-Type:** `multipart/form-data`
* **Authentication:** Optional/Required (passes Authorization header if available)
* **Request Payload:**
  * **Fields:**
    * `cust_name`: `"Alice Smith"`
    * `cust_email`: `"alice@example.com"`
    * `cust_phone`: `"+15555551234"`
    * `pet_name`: `"Buddy"`
    * `pet_type`: `"Dog"`
    * `price`: `"250.00"`
    * `size`: `"Medium"`
    * `installation_surface`: `"Wood Door"`
    * `service_area_id`: `"3"` (String representation of integer ID)
    * `address_line_1`: `"123 Main St"`
    * `address_line_2`: `"Apt 4B"` (optional)
    * `city`: `"New York"`
    * `state`: `"NY"`
    * `zip_code`: `"10001"`
    * `country`: `"USA"`
  * **Files:**
    * `photos`: Binary Image File (The attachment containing door location photo)
* **Response (Status 201 Created):**
  ```json
  {
    "status": "success",
    "message": "Service request submitted successfully",
    "post_id": "post_uuid_here"
  }
  ```

### 4.2 Fetch Customer Service Posts (Service History)
Lists all service requests created by the authenticated customer.

* **Method:** `GET`
* **Endpoint:** `/customer/posts/`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  {
    "posts": [
      {
        "id": "pst_11223344",
        "pet_name": "Buddy",
        "pet_type": "Dog",
        "size": "Medium",
        "photos": [
          "https://example.com/uploads/posts/post_1.jpg"
        ],
        "address": "123 Main St, Apt 4B, New York, NY, 10001, USA", // Client reads "Address" or "address"
        "price": 250.00,
        "status": "pending", // e.g. "pending", "receiving_bids", "installer_assigned", "in_progress", "completed"
        "installer_id": "usr_9988", // optional
        "installation_surface": "Wood Door",
        "created_at": "2026-07-02T14:00:00Z",
        "updated_at": "2026-07-02T14:10:00Z",
        "scheduled_date": "2026-07-05T09:00:00Z", // optional
        "note": "Wood door installation", // optional
        "additional_service_note": "",
        "customer_satisfaction_note": "",
        "area_id": 3,
        "is_additional_service": false,
        "is_customer_satisfied": false
      }
    ]
  }
  ```

### 4.3 Fetch Bids on Post
Retrieves bids placed by installers on a specific post.

* **Method:** `GET`
* **Endpoint:** `/customer/posts-bids/`
* **Authentication:** Required
* **Query Parameters:**
  * `post_id`: `pst_11223344` (String, required)
* **Response (Status 200 OK):**
  ```json
  {
    "bids": [
      {
        "id": "bid_8899",
        "status": "pending", // "pending", "accepted", "rejected"
        "post_request_id": "pst_11223344",
        "installer_id": "usr_7777",
        "note": "Can complete it this Friday morning.",
        "price": 240.00,
        "created_at": "2026-07-02T14:05:00Z",
        "updated_at": "2026-07-02T14:05:00Z"
      }
    ]
  }
  ```

### 4.4 Accept Bid
Accepts an installer's bid on a job.

* **Method:** `POST`
* **Endpoint:** `/customer/bid/{bid_id}/accept/`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:** None (Empty Body)
* **Response (Status 200 OK):**
  ```json
  {
    "status": "success",
    "message": "Bid accepted successfully"
  }
  ```

### 4.5 Submit Installer Review
Submits rating and text feedback for the installer who completed the job.

* **Method:** `POST`
* **Endpoint:** `/customer/review`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "installer_id": "usr_7777",
    "rating": 5, // integer 1-5
    "review": "Excellent service and quick installation!"
  }
  ```
* **Response (Status 200 OK):**
  ```json
  {
    "status": "success",
    "message": "Review submitted successfully"
  }
  ```

### 4.6 Fetch Installer Ratings
Retrieves average ratings and review metrics for installers (used in features like Happy Tails).

* **Method:** `GET`
* **Endpoint:** `/installer/installer-ratings`
* **Authentication:** Required
* **Query Parameters:**
  * `skip`: `0` (int, optional, default: 0)
  * `limit`: `10` (int, optional, default: 10)
* **Response (Status 200 OK):**
  Returns a List directly, or a Map containing the key `"ratings"`, `"items"`, or `"results"` containing the list of reviews. Each rating object contains:
  ```json
  [
    {
      "installer_id": "usr_7777",
      "installer_name": "Installer Bob", // fallback key: "installer name" (with space)
      "installer_photo": "https://example.com/bob.jpg",
      "average_rating": 4.8,
      "total_reviews": 15
    }
  ]
  ```

### 4.7 Manage Customer Pets (CRUD)

#### 4.7.1 Fetch Pets List
* **Method:** `GET`
* **Endpoint:** `/customer/pets/`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  {
    "pets": [
      {
        "id": "pet_1122",
        "name": "Buddy",
        "type": "Dog",
        "size": "Medium",
        "breed": "Golden Retriever" // optional
      }
    ]
  }
  ```

#### 4.7.2 Create Pet
* **Method:** `POST`
* **Endpoint:** `/customer/pets/`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "name": "Buddy",
    "type": "Dog",
    "size": "Medium",
    "breed": "Golden Retriever" // optional
  }
  ```
* **Response (Status 200 OK):** Returns success status.

#### 4.7.3 Update Pet
* **Method:** `PUT`
* **Endpoint:** `/customer/pets/{pet_id}/`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:** Same as Create Pet body.
* **Response (Status 200 OK):** Returns success status.

#### 4.7.4 Delete Pet
* **Method:** `DELETE`
* **Endpoint:** `/customer/pets/{pet_id}/`
* **Authentication:** Required
* **Response (Status 200 OK):** Returns success status.

---

## 5. Installer Features & Availability

### 5.1 Service Area Options

#### 5.1.1 Fetch All Available Service Areas
Lists all general service areas registered on the system.

* **Method:** `GET`
* **Endpoint:** `/installer/service-areas`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  [
    {
      "id": 1,
      "name": "North Texas"
    },
    {
      "id": 2,
      "name": "Dallas County"
    }
  ]
  ```

#### 5.1.2 Fetch Assigned Service Areas (For Installer)
Lists service areas assigned to the authenticated installer.

* **Method:** `GET`
* **Endpoint:** `/installer/installer/service-areas`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  [
    {
      "area_id": 1,
      "area__name": "North Texas" // Note: Double underscores
    }
  ]
  ```

#### 5.1.3 Update Installer Service Areas
Updates the active service areas for the installer.

* **Method:** `POST`
* **Endpoint:** `/installer/installer/service-areas`
* **Authentication:** Required
* **Request Payload (JSON):**
  ```json
  {
    "area_ids": [1, 2]
  }
  ```
* **Response (Status 200 OK):** Status code validation.

### 5.2 Installer Availability

#### 5.2.1 Get Availability
* **Method:** `GET`
* **Endpoint:** `/installer/installer-availability-get/`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  {
    "id": "av_001",
    "installer_id": "usr_7777",
    "is_available": true,
    "active_hours_per_week": 40,
    "active_hourse_par_week": 40, // Legacy spelling fallback
    "week_hours": 40,            // Alternate fallback
    "created_at": "2026-06-01T12:00:00Z",
    "updated_at": "2026-07-02T10:00:00Z"
  }
  ```

#### 5.2.2 Update Availability
* **Method:** `POST`
* **Endpoint:** `/installer/installer-availability/`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "is_available": true,
    "week_hours": 40 // sent as integer representation
  }
  ```
* **Response (Status 200 OK):** Success confirmation.

### 5.3 Earnings & Payment Settings

#### 5.3.1 Fetch Monthly Earnings Summary
* **Method:** `GET`
* **Endpoint:** `/installer/installer/earnings/`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  {
    "installer_id": "usr_7777",
    "in_progress_count": 2,
    "completed_count": 14,
    "earnings": 3500.00,
    "commission": 350.00,
    "commision": 350.00 // Legacy/fallback spelling
  }
  ```

#### 5.3.2 Check Stripe Ready Status
Checks whether the installer is fully onboarded and ready to receive Stripe payouts.

* **Method:** `GET`
* **Endpoint:** `/payment/account-is-ready`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  {
    "detail": "active", // Or "installer not ready for payments"
    "message": "ready"
  }
  ```
  *(Note: Response is interpreted as 'not ready' if the message contains `"installer not ready for payments"`.)*

#### 5.3.3 Create Stripe Connected Account
Creates a Stripe custom/express account for the installer.

* **Method:** `POST`
* **Endpoint:** `/payment/installer/stripe/create-account`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:** None (Empty Body)
* **Response (Status 200 OK):** Success confirmation.

#### 5.3.4 Create Stripe Onboarding Link
Generates onboarding link for the newly created Stripe connected account.

* **Method:** `POST`
* **Endpoint:** `/payment/installer/stripe/onboarding-link`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:** None (Empty Body)
* **Response (Status 200 OK):**
  ```json
  {
    "url": "https://connect.stripe.com/setup/s/..."
  }
  ```

#### 5.3.5 Fetch Payments List (For Installer)
Lists payment history for the installer.

* **Method:** `GET`
* **Endpoint:** `/payment/installer/payments/`
* **Authentication:** Required
* **Query Parameters:**
  * `user_id`: `"usr_7777"` (String, required)
  * `skip`: `0` (int, default: 0)
  * `limit`: `10` (int, default: 10)
* **Response (Status 200 OK):**
  * *Note: Can return array directly or wrapped in `results`, `data` or `items` key.*
  ```json
  {
    "results": [
      {
        "id": "pay_98765",
        "amount": 250.00,
        "status": "succeeded", // "pending", "succeeded", "failed"
        "payment_type": "job_payout",
        "created_at": "2026-07-01T15:30:00Z",
        "installer_id": "usr_7777",
        "stripe_payment_intent_id": "pi_3M..."
      }
    ]
  }
  ```

### 5.4 Installer Job Management (Bids & Statuses)

#### 5.4.1 Fetch Installer Post List (Grouped)
Fetches jobs, separating new bids and assigned jobs.

* **Method:** `GET`
* **Endpoint:** `/customer/posts/`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  {
    "new_posts": [
      {
        "id": "pst_12345",
        "pet_name": "Max",
        "pet_type": "Cat",
        "size": "Small",
        "photos": ["/media/job1.jpg"],
        "Address": "456 Oak Ave, Dallas, TX",
        "price": 180.00,
        "status": "receiving_bids",
        "installation_surface": "Wall",
        "created_at": "2026-07-02T10:00:00Z",
        "scheduled_date": null
      }
    ],
    "assigned_post": [
      {
        "id": "pst_67890",
        "pet_name": "Bella",
        "pet_type": "Dog",
        "size": "Large",
        "photos": ["/media/job2.jpg"],
        "Address": "789 Pine Rd, Plano, TX",
        "price": 320.00,
        "status": "in_progress",
        "installer_id": "usr_7777",
        "installation_surface": "Glass Slider",
        "created_at": "2026-06-30T10:00:00Z",
        "scheduled_date": "2026-07-03T14:00:00Z"
      }
    ]
  }
  ```
  *(Note: Fallback is to read the `"posts"` list if `new_posts` and `assigned_post` are missing.)*

#### 5.4.2 Submit Bid on Post
* **Method:** `POST`
* **Endpoint:** `/customer/posts/{post_id}/bids/`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "price": 280.00, // sent as double/float value
    "note": "I can fit this next Monday."
  }
  ```
* **Response (Status 200 OK):** Success confirmation.

#### 5.4.3 Accept Installer Post
Marks a bidding post as accepted by the installer (assigned directly).

* **Method:** `POST`
* **Endpoint:** `/customer/post/{post_id}/accept/`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:** None (Empty Body)
* **Response (Status 200 OK):** Success confirmation.

#### 5.4.4 Update Post Status & Completion Details
Applies updates to job status, scheduling, and optional additional service details or customer satisfaction surveys.

* **Method:** `PATCH`
* **Endpoint:** `/customer/posts/{post_id}/update/`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "note": "Completed installation successfully.", // String
    "new_status": "completed",                      // String, optional (e.g. "in_progress", "completed")
    "scheduled_date": "2026-07-03T14:00:00.000Z",    // ISO8601 UTC String, optional
    "is_additional_service": true,                  // bool, optional
    "additional_service_note": "Installed extra safety lock.", // String, optional
    "is_customer_satisfied": true,                  // bool, optional
    "customer_satisfaction_note": "Customer was very happy."  // String, optional
  }
  ```
* **Response (Status 200 OK):** Success confirmation.

---

## 6. Payments Integration (Stripe & Cash)

### 6.1 Create Stripe Payment Intent (Customer Payment for Job)
Generates Stripe Payment Intent client secret to confirm payments on mobile devices.

* **Method:** `POST`
* **Endpoint:** `/payment/payments/create` (query param `?post_id=post_uuid` is appended)
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Query Parameters:**
  * `post_id`: `pst_11223344` (String, required)
* **Request Payload:** None (Empty Body)
* **Response (Status 200 OK):**
  ```json
  {
    "client_secret": "pi_12345_secret_abc123"
  }
  ```
  *(Note: Response might contain keys: `client_secret`, `clientSecret`, `payment_intent_client_secret` or `paymentIntentClientSecret`)*

### 6.2 Pay with Cash
Creates a record for cash payment, skipping online payment flow.

* **Method:** `POST`
* **Endpoint:** `/payment/cash-payment/`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "post_id": "pst_11223344"
  }
  ```
* **Response (Status 200 OK):** Success confirmation.

### 6.3 Create Installer Commission Stripe Intent
Generates Stripe intent for payment of platform commission by installer.

* **Method:** `POST`
* **Endpoint:** `/payment/payments/create`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "amount": "35.00",
    "payment_type": "commission"
  }
  ```
* **Response (Status 200 OK):**
  ```json
  {
    "client_secret": "pi_98765_secret_xyz789",
    "message": "Payment intent created",
    "payment": {
      "id": "pay_xyz",
      "amount": 35.00,
      "status": "pending",
      "payment_type": "commission",
      "created_at": "2026-07-02T14:15:00Z",
      "installer_id": "usr_7777",
      "stripe_payment_intent_id": "pi_98765"
    }
  }
  ```

### 6.4 Manual Stripe Webhook Notification
Used by mobile client to notify backend after completing/failing payment sheets manually.

* **Method:** `POST`
* **Endpoint:** `/payment/stripe/manual-webhook?payment_id={payment_id}&status={true_or_false}`
* **Authentication:** Required (passes Authorization token if available)
* **Request Payload:** None (Empty Body)
* **Response (Status 200 OK):** Success confirmation.

---

## 7. Admin Dashboard & Job Settings

### 7.1 Fetch Recent Jobs List (Dashboard)
Lists jobs globally on the admin dashboard.

* **Method:** `GET`
* **Endpoint:** `/admin/recent-jobs/`
* **Authentication:** Required
* **Query Parameters:**
  * `offset`: `0` (int, required)
  * `limit`: `10` (int, required)
* **Response (Status 200 OK):**
  The response can be a List directly, or a Map containing the key `"jobs"` or `"results"` containing the list of jobs. Each job in the list must have the following structure:
  ```json
  [
    {
      "id": "pst_12345",
      "created_at": "2026-07-02T10:00:00Z",
      "updated_at": "2026-07-02T10:00:00Z",
      "installation_surface": "Wall", // fallback key: "door_type"
      "status": "receiving_bids", // e.g. "pending", "receiving_bids", "installer_assigned", "in_progress", "completed"
      "price": 280.00,
      "photos": [
        "https://example.com/door.jpg"
      ],
      "address_line_1": "123 Main St",
      "address_line_2": "Apt 4B",
      "city": "Dallas",
      "state": "TX",
      "zip_code": "75001",
      "country": "USA",
      "Address": "123 Main St, Apt 4B, Dallas, TX, 75001, USA", // fallback keys: "address", "location"
      "job_number": "JOB_J8972", // fallback key: "job_no"
      "customer_name": "Alice Smith", // fallback keys: "pet_name", "customer_id"
      "bid_count": 3, // fallback key: "bids_count"
      "pet_name": "Rocky",
      "pet_type": "Dog",
      "size": "Large",
      "note": "Install on wall", // fallback keys: "additional_service_note", "job_notes"
      "scheduled_date": "2026-07-04T12:00:00Z",
      "job_status_notes": "Installer completed part 1",
      "is_additional_service": false, // fallback key: "additional_work_answer"
      "additional_service_note": "",
      "is_customer_satisfied": true, // fallback key: "customer_satisfied_answer"
      "customer_satisfaction_note": "" // fallback key: "customer_feedback"
    }
  ]
  ```

### 7.2 Fetch Recent Bids List
Lists bids globally on the admin dashboard.

* **Method:** `GET`
* **Endpoint:** `/admin/recent-bids`
* **Authentication:** Required
* **Query Parameters:**
  * `offset`: `0` (int, required)
  * `limit`: `10` (int, required)
* **Response (Status 200 OK):**
  The response can be a List directly, or a Map containing the key `"bids"` or `"results"` containing the list of bids. Each bid has the following structure:
  ```json
  [
    {
      "id": "bid_8899",
      "installer_id": "usr_7777",
      "post_request_id": "pst_12345",
      "note": "Quick install",
      "created_at": "2026-07-02T10:05:00Z",
      "price": 280.00
    }
  ]
  ```

### 7.3 Fetch Post Statistics
Retrieves counts of posts across different categories for the admin dashboard.

* **Method:** `GET`
* **Endpoint:** `/admin/post-stats`
* **Authentication:** Required
* **Response (Status 200 OK):**
  The response can be a Map directly, or nested inside a top-level `"data"` key.
  ```json
  {
    "new_job_count": 5,
    "pending_bid_count": 12,
    "installer_assigned_count": 8,
    "deu_count": 1
  }
  ```

### 7.4 Job Management Settings

#### 7.4.1 Get Job Settings
* **Method:** `GET`
* **Endpoint:** `/admin/job-management-settings`
* **Authentication:** Required
* **Response (Status 200 OK):**
  The response can be a Map directly, or nested inside a top-level `"data"` key.
  ```json
  {
    "id": 1,
    "job_timeout_hours": 24,
    "auto_assign_job": true
  }
  ```

#### 7.4.2 Update Job Settings
* **Method:** `POST`
* **Endpoint:** `/admin/job-management-settings`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "auto_assign_job": "true", // Note: sent as String ("true" or "false")
    "job_timeout_hours": "24"  // Note: sent as String representation of int
  }
  ```
* **Response (Status 200 OK):** Returns the updated settings JSON (same schema as `7.4.1`).

### 7.5 Payment Commission Settings

#### 7.5.1 Get Payment Settings Status
* **Method:** `GET`
* **Endpoint:** `/admin/payment-settings/`
* **Authentication:** Required
* **Response (Status 200 OK):**
  ```json
  {
    "id": 1,
    "updated_at": "2026-07-02T14:00:00Z",
    "status": true // represents active status
  }
  ```

#### 7.5.2 Update Payment Settings Status
* **Method:** `POST`
* **Endpoint:** `/admin/payment-settings/`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "new_status": "true" // sent as String ("true" or "false")
  }
  ```
* **Response (Status 200 OK):** Same Payment settings JSON (same schema as `7.5.1`).

### 7.6 Admin Create Post (Direct Assign/Create)
Allows the admin to post a job directly, specifying one or more installers to notify or assign.

* **Method:** `POST`
* **Endpoint:** `/admin/posts-admin/`
* **Content-Type:** `multipart/form-data`
* **Authentication:** Required
* **Request Payload:**
  * **Fields:**
    * `size`: `"Large"` (String)
    * `cust_phone`: `"+15551234"` (String)
    * `installation_surface`: `"Wall"` (String)
    * `service_area_id`: `"2"` (String representation of integer service area ID)
    * `price`: `"350.00"` (String representation of labor price)
    * `pet_name`: `"Rocky"` (String)
    * `inst_ids`: `"usr_7777,usr_6666"` (Comma-separated string of preferred installer IDs)
    * `cust_email`: `"cust@example.com"` (String)
    * `address_line_1`: `"789 Pine Rd"` (String)
    * `address_line_2`: `""` (String, optional)
    * `city`: `"Plano"` (String)
    * `state`: `"TX"` (String)
    * `zip_code`: `"75023"` (String)
    * `country`: `"USA"` (String)
    * `cust_name`: `"Alice Cooper"` (String)
    * `pet_type`: `"Dog"` (String)
  * **Files:**
    * `photos`: Multiple image and attachment files uploaded under the same key `"photos"`.
* **Response (Status 201 Created):** Returns success representation.

### 7.7 Admin Fetch Assigned Posts List
* **Method:** `GET`
* **Endpoint:** `/admin/posts-admin/`
* **Authentication:** Required
* **Query Parameters:**
  * `offset`: `0` (int, required)
  * `limit`: `10` (int, required)
* **Response (Status 200 OK):**
  The response can be a List directly, or a Map containing one of the following keys: `"posts"`, `"results"`, `"items"`, `"data"`, `"assigned_post"`, or `"new_posts"` containing the list of jobs. Each job in the list has the same schema as described in `7.1`.

### 7.8 Admin Create Service Area
Adds a new service area option.

* **Method:** `POST`
* **Endpoint:** `/admin/service-areas`
* **Content-Type:** `application/x-www-form-urlencoded`
* **Authentication:** Required
* **Request Payload:**
  ```json
  {
    "name": "Collin County"
  }
  ```
* **Response (Status 201 Created):** Returns the created area details.

### 7.9 Admin Mark Payment Paid (Manual Commission Approval)
Updates commission payments from installers manually.

* **Method:** `PUT`
* **Endpoint:** `/payment/installer/payments/{payment_id}/mark-paid`
* **Authentication:** Required
* **Query Parameters:**
  * `action`: `"mark_paid"` (String, required)
* **Response (Status 200 OK):**
  The response can be the payment object directly, or wrapped in the keys `"payment"`, `"data"`, or `"result"`. The payment object has the following structure:
  ```json
  {
    "amount": 250.00,
    "status": "paid", // "pending", "succeeded", "success", "paid", "received", "rejected", "failed"
    "id": "pay_98765",
    "payment_type": "commission",
    "created_at": "2026-07-01T15:30:00Z",
    "installer_id": "usr_7777",
    "stripe_payment_intent_id": "pi_3M..."
  }
  ```

### 7.10 Fetch User Management List (Admin)
Retrieves the list of users (both customers and installers).

* **Method:** `GET`
* **Endpoint:** `/user/users/`
* **Authentication:** Required
* **Query Parameters:**
  * `offset`: `0` (int, required)
  * `limit`: `15` (int, required)
* **Response (Status 200 OK):**
  ```json
  {
    "total": 45,
    "offset": 0,
    "limit": 15,
    "count": 15,
    "results": [
      {
        "id": "usr_7777",
        "name": "Installer Bob",
        "email": "bob@example.com",
        "phone": "+15558888",
        "created_at": "2026-06-01T12:00:00Z", // fallback key: "joined_date"
        "joined_date": "2026-06-01T12:00:00Z",
        "photo": "https://example.com/bob.jpg", // fallback key: "profile_image_url"
        "profile_image_url": "https://example.com/bob.jpg",
        "is_active": true, // If false, the user is interpreted as suspended
        "is_suspended": false,
        "role": "installer", // normalises to "installer" or "customer"
        "user_type": "installer"
      }
    ]
  }
  ```

### 7.11 Suspend / Unsuspend User (Admin)
Suspends or reactivates a user's account.

* **Method:** `PATCH`
* **Endpoint:** `/user/users/suspend`
* **Authentication:** Required
* **Query Parameters:**
  * `user_id`: `"usr_7777"` (String, required)
* **Response (Status 200 OK):** Success confirmation.

### 7.12 Delete User (Admin)
Deletes a user account.

* **Method:** `DELETE`
* **Endpoint:** `/user/users/{user_id}`
* **Authentication:** Required
* **Response (Status 200 OK):** Success confirmation.

---

## 8. Push Notifications

### 8.1 Register/Save Firebase FCM Token
Saves push token linked to authenticated user and platform.

* **Method:** `POST`
* **Endpoint:** `/communications/save_token/`
* **Authentication:** Required
* **Request Payload (JSON):**
  ```json
  {
    "user_id": "usr_98234710",
    "token": "fcm_token_string_here",
    "platform": "ios" // or "android"
  }
  ```
* **Response (Status 200 OK):**
  ```json
  {
    "status": "success",
    "message": "Token saved successfully"
  }
  ```

---

## 9. Real-time Messaging & WebSockets

### 9.1 Start Chat Session
Registers a chat session window between two users.

* **Method:** `POST`
* **Endpoint:** `/communications/chat/start/{from_type}/{from_id}/{to_type}/{to_id}`
* **Authentication:** Required
* **Path Parameters:**
  * `from_type`: singular user type (`customer`, `installer`, `admin`)
  * `from_id`: UUID/String user ID
  * `to_type`: singular user type (`customer`, `installer`, `admin`)
  * `to_id`: UUID/String user ID
* **Response (Status 200 OK):** Returns success.

### 9.2 End Chat Session
Unregisters the active session window.

* **Method:** `POST`
* **Endpoint:** `/communications/chat/end/{from_type}/{from_id}/{to_type}/{to_id}`
* **Authentication:** Required
* **Path Parameters:** Same as `/chat/start`.
* **Response (Status 200 OK):** Returns success.

### 9.3 Fetch Chat Partners List
Lists users the current user has chatted with.

* **Method:** `GET`
* **Endpoint:** `/communications/chat/partners/{type_path}/{user_id}`
* **Authentication:** Required
* **Path Parameters:**
  * `type_path`: plural WS type (`customers`, `installers`, `admins`)
  * `user_id`: UUID/String user ID
* **Response (Status 200 OK):**
  ```json
  {
    "partners": [
      {
        "type": "installers",
        "id": "usr_7777",
        "user_name": "Bob (Installer)",
        "last_message_at": "2026-07-02T14:10:00Z" // ISO8601 String
      }
    ]
  }
  ```

### 9.4 Fetch Messaging History
* **Method:** `GET`
* **Endpoint:** `/communications/chat/history/{from_type}/{from_id}/{to_type}/{to_id}`
* **Authentication:** Required
* **Query Parameters:**
  * `limit`: `50` (int, optional)
* **Path Parameters:**
  * `from_type`: plural WS type (`customers`, `installers`, `admins`)
  * `from_id`: UUID/String
  * `to_type`: plural WS type (`customers`, `installers`, `admins`)
  * `to_id`: UUID/String
* **Response (Status 200 OK):**
  ```json
  {
    "messages": [
      {
        "message_id": "msg_998877",
        "from_type": "customers",
        "from_id": "usr_98234710",
        "from_name": "Alice Smith",
        "text": "Hi, are you arriving soon?",
        "timestamp": "2026-07-02T14:10:00Z",
        "is_read": true,
        "edited_at": null,
        "is_deleted": false,
        "reactions": {
          "👍": 1
        },
        "media_type": null,
        "media_url": null,
        "is_offline_message": false
      }
    ]
  }
  ```

### 9.5 WebSocket Server Integration

* **Connection URL:**
  * Scheme: `ws` (non-secure) or `wss` (secure)
  * Format: `ws://187.124.228.249:8000/communications/ws/chat/{user_type_plural}/{user_id}`
    * `user_type_plural` **MUST** be: `customers`, `installers`, or `admins`
    * `user_id`: UUID/ID of the connecting user.

#### 9.5.1 Client -> Server JSON Actions

All payloads sent by the app contain an `"action"` parameter:

1. **Send Message:**
   ```json
   {
     "action": "send",
     "to_type": "customers | installers | admins",
     "to_id": "receiver_id_string",
     "text": "Message text here",
     "from_name": "My Display Name",
     "media_type": "image/jpeg", // optional
     "media_url": "https://example.com/uploads/photo.jpg" // optional
   }
   ```
2. **Edit Message:**
   ```json
   {
     "action": "edit",
     "message_id": "msg_998877",
     "new_text": "Updated message text"
   }
   ```
3. **Delete Message:**
   ```json
   {
     "action": "delete",
     "message_id": "msg_998877"
   }
   ```
4. **React to Message:**
   ```json
   {
     "action": "react",
     "message_id": "msg_998877",
     "reaction": "❤️" // Emoji string
   }
   ```
5. **Remove Reaction:**
   ```json
   {
     "action": "remove_react",
     "message_id": "msg_998877",
     "reaction": "❤️" // Emoji string
   }
   ```

#### 9.5.2 Server -> Client JSON Events

The client application listens for events with a `"type"` parameter:

1. **Messaging Event (`"type": "messaging"`):**
   Broadcasted when a message is sent, edited, deleted, or reacted to.
   ```json
   {
     "type": "messaging",
     "action": "send", // "send", "edit", "delete", "react", "remove_react"
     "id": "msg_998877", // or "message_id"
     "message_id": "msg_998877",
     "from_id": "sender_id_string",
     "from_name": "Sender Name",
     "from_type": "installers",
     "text": "Message text", // or "new_text" if editing
     "media_type": null,
     "media_url": null,
     "timestamp": "2026-07-02T14:10:00Z",
     "edited_at": null,
     "is_deleted": false,
     "reactions": {},
     "is_offline_message": false
   }
   ```
2. **Control Event (`"type": "control"`):**
   Used to update state details or reactions dynamically.
   ```json
   {
     "type": "control",
     "action": "react", // "react", "remove_react", "edit", "delete"
     "message_id": "msg_998877",
     "reaction": "❤️",
     "user": "installers:usr_7777", // actor format type:id
     "new_text": "text" // if edit
   }
   ```
3. **Status Acknowledgment Event:**
   Acknowledges action requests.
   ```json
   {
     "status": "sent", // "sent", "message_sent", "edited", "deleted", "reacted", "unreacted", "reaction_removed"
     "message_id": "msg_998877"
   }
   ```
4. **Error Event:**
   ```json
   {
     "error": "Message failed to send",
     "detail": "Recipient session not found"
   }
   ```

---

## 10. Summary of Backward Compatibility / Casing Notes

Please ensure the backend handles these specific spelling and casing fallbacks, which the Flutter application expects:

* **Commission Spelling:** The client checks for **`commision`** (one 's') and **`commission`** in `/installer/installer/earnings/` response.
* **Installer Week Hours:** The client checks for **`active_hourse_par_week`** (spelled `hourse` and `par`), **`active_hours_per_week`**, and **`week_hours`** in `/installer/installer-availability-get/`.
* **Assigned Service Area Name:** In GET `/installer/installer/service-areas`, the service area name is parsed from the key **`area__name`** (double underscore).
* **Address Key Fallback:** In customer post history, the client checks both **`Address`** (uppercase A) and **`address`** (lowercase a).
