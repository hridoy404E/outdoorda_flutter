class AppStrings {
  AppStrings._();

  // Forgot Password Flow Strings
  static const String forgotPasswordTitle = 'Forgot Password?';
  static const String forgotPasswordSubtitle =
      "Enter your email and we'll send you an OTP to reset your password.";
  static const String emailLabel = 'Email';
  static const String emailPlaceholder = 'Enter your email';
  static const String sendResetPasswordLink = 'Send OTP';

  // OTP Verification Strings
  static const String otpVerificationTitle = 'OTP Verification';
  static const String otpVerificationSubtitle =
      'Enter the verification code we just sent to your email address.';
  static const String otpLabel = 'OTP Code';
  static const String verifyOTP = 'Verify OTP';
  static const String resendOTP = 'Resend OTP';
  static const String didNotReceiveCode = "Didn't receive code?";

  // Reset Password Strings
  static const String resetPasswordTitle = 'Reset Password?';
  static const String resetPasswordSubtitle =
      'Please enter a new password & confirm to reset your password';
  static const String passwordLabel = 'Password';
  static const String passwordPlaceholder = 'Enter your password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordPlaceholder = 'Confirm your password';
  static const String resetPassword = 'Reset Password';

  // Success Messages
  static const String emailSentSuccess = 'OTP sent to your email!';
  static const String otpVerifiedSuccess = 'OTP verified successfully!';
  static const String passwordResetSuccess = 'Password reset successfully!';

  // Error Messages
  static const String emailSendError = 'Failed to send OTP';
  static const String otpVerifyError = 'Failed to verify OTP';
  static const String passwordResetError = 'Failed to reset password';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidOTP = 'Please enter a valid OTP code';

  static const String appName = 'OutdoorDa';

  // Authentication Screen Texts
  static const String welcomeBack = 'Welcome back';
  static const String createYourAccount = 'Create your account';
  static const String enterEmailPasswordAccess =
      'Enter your email and password to access your account';
  static const String enterEmailPasswordCreate =
      'Enter your email and password to create your account';

  // User Types
  static const String admin = 'Admin';
  static const String installer = 'Installer';
  static const String customer = 'Customer';

  // Form Labels
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';

  // Placeholders
  static const String enterYourEmail = 'Enter your email';
  static const String enterYourPassword = 'Enter your password';
  static const String confirmYourPassword = 'Confirm your password';
  static const String enterYourFullName = 'Enter your full name';

  // Buttons
  static const String logIn = 'Log In';
  static const String registerNow = 'Register Now';
  static const String forgotPassword = 'Forgot Password?';
  static const String rememberMe = 'Remember me';

  // Navigation
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String logInNow = 'Log In Now';
  static const String dontHaveAccount = "Don't have an account?";
  static const String signUpNow = 'Sign Up Now';

  // Agreement
  static const String iAgreeToThetaAnalyzer = 'I agree to the ';
  static const String licenseAgreement = 'License Agreement';
  static const String and = ' and ';
  static const String privacyPolicy = 'Privacy Policy';

  // Validation Messages
  static const String requiredField = 'This field is required';
  // static const String invalidEmail = 'Invalid email address';
  static const String invalidPassword = 'Invalid password';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // Service Request Screen Strings
  static const String goodMorning = 'Good Morning';
  static const String ongoing = 'Ongoing';
  static const String quickActions = 'Quick Actions';
  static const String newRequest = 'New Request';
  static const String message = 'Message';
  static const String helpCenter = 'Help Center';
  static const String yourHistory = 'Your History';
  static const String happyTails = 'Happy Tails';

  // Service Status
  static const String installerAssigned = 'Installer Assigned';
  static const String receivingBids = 'Receiving Bids';
  static const String completed = 'Completed';
  static const String bidsPending = 'Bids\nPending';
  static const String noBidYet = 'No Bid Yet';

  // Service Details
  static const String assignedInstaller = 'Assigned Installer';

  // All Requests Screen Strings
  static const String myRequests = 'My Requests';

  // Request Details Screen Strings
  static const String requestDetails = 'Request Details';
  static const String status = 'Status';
  static const String youHaveReceivedProposals =
      'You have received 3 proposals from installers.';
  static const String availablePrefix = 'Available ';
  static const String chat = 'Chat';
  static const String acceptOffer = 'Accept Offer';
  static const String offerAcceptedSuccess = 'Offer accepted successfully!';
  static const String offerAcceptError = 'Failed to accept offer';
  static const String preparingPayment = 'Preparing payment...';
  static const String paymentCancelled = 'Payment cancelled';
  static const String paymentFailed = 'Payment failed. Please try again.';
  static const String choosePaymentMethod = 'Choose Payment Method';
  static const String payWithStripe = 'Pay with Stripe';
  static const String payWithStripeSubtitle = 'Secure card payment via Stripe';
  static const String payWithCashOffline = 'Pay with Cash (Offline)';
  static const String payWithCashOfflineSubtitle =
      'No action now. API will be added later';
  static const String markAsCompleted = 'Mark as Completed';
  static const String confirmCompletion = 'Confirm Completion';
  static const String confirmCompletionMessage =
      'Are you sure you want to mark this work as completed?';
  static const String installationDetails = 'INSTALLATION DETAILS';
  static const String serviceType = 'Service Type:';
  static const String petDoor = 'Pet Door';
  static const String doorInstallation = 'Door Installation';
  static const String patioPanel = 'Patio Panel';
  static const String pet = 'Pet:';
  static const String priceQuote = 'Price Quote';
  static const String pending = 'Pending';
  static const String reviews = 'reviews';

  // Add Service Request Bottom Sheet Strings
  static const String requestService = 'Request Service';
  static const String letsStartWithWhoThisDoorIsFor =
      "Let's start with who this door is for.";
  static const String petName = 'Pet Name';
  static const String petNamePlaceholder = 'Enter pet name';
  static const String type = 'Type';
  static const String typePlaceholder = 'Pet type';
  static const String size = 'Size';
  static const String sizePlaceholder = 'Pet size';
  static const String nextInstallation = 'Next: Installation';
  static const String whereShouldWeInstallTheDoor =
      'Where should we install the door?';
  static const String address = 'Address';
  static const String addressPlaceholder = 'Enter installation address';
  static const String installationSurface = 'Installation Surface';
  static const String door = 'Door';
  static const String wall = 'Wall';
  static const String glass = 'Glass';
  static const String other = 'Other';
  static const String serviceArea = 'Service Area';
  static const String selectServiceArea = 'Select service area';
  static const String loadingServiceAreas = 'Loading service areas...';
  static const String noServiceAreasAvailable = 'No service areas available';
  static const String back = 'Back';
  static const String nextPhotos = 'Next: Photos';
  static const String helpUsSeeDoorInstallationArea =
      'Help us see the installation area.';
  static const String uploadAttachmentForInstallationArea =
      'Upload a clear image or file of the installation area';
  static const String browseFile = 'Browse File';
  static const String camera = 'Camera';
  static const String image = 'Image';
  static const String file = 'File';
  static const String attachmentSelected = 'Attachment selected';
  static const String submitRequest = 'Submit Request';
  static const String requestSubmittedSuccessfully =
      'Request submitted successfully!';
  static const String pleaseEnterPetName = 'Please enter pet name';
  static const String pleaseSelectType = 'Please select type';
  static const String pleaseSelectSize = 'Please select size';
  static const String pleaseEnterAddress = 'Please enter address';
  static const String pleaseSelectInstallationSurface =
      'Please select installation surface';
  static const String pleaseSelectServiceArea = 'Please select service area';
  static const String pleaseUploadAttachment = 'Please upload an attachment';
  static const String serviceAreasLoadError =
      'Unable to load service areas right now.';
  static const String loadingBids = 'Loading bids...';
  static const String noBidsYet = 'No bids yet';
  static const String authorizationRequired =
      'Authorization missing. Please log in again.';

  // Messaging Screens
  static const String messages = 'Messages';
  static const String messageInputPlaceholder = 'Describe what you want to see';
  static const String sendMessage = 'Send Message';
  static const String noMessages = 'No messages yet';
  static const String startConversation = 'Start a conversation';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String typing = 'Typing...';
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String messageDeleted = 'This message was deleted';
  static const String messageSent = 'Message sent';
  static const String messageFailed = 'Failed to send message';
  static const String unreadMessages = 'unread messages';
  static const String noConversations = 'No conversations yet';
  static const String searchConversations = 'Search conversations';
  static const String newMessage = 'New Message';
  static const String attachPhoto = 'Attach Photo';
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';

  // Settings Screen Strings
  static const String settings = 'Settings';
  static const String editProfile = 'Edit Profile';
  static const String myPets = 'My Pets';
  static const String addNewPet = 'Add New Pet';
  static const String notifications = 'Notifications';
  static const String paymentMethods = 'Payment Methods';
  static const String privacyAndSecurity = 'Privacy & Security';
  static const String support = 'Support';
  static const String logOut = 'Log Out';
  static const String deleteAccount = 'Delete Account';
  static const String delete = 'Delete';
  static const String deleteAccountTitle = 'Delete Account';
  static const String deleteAccountConfirmation =
      'Are you sure you want to delete your account? This action cannot be undone.';
  static const String accountDeletedSuccess = 'Account deleted successfully';

  // Pet Management Strings
  static const String petNameLabel = 'Pet Name';
  static const String petTypePlaceholder = 'Select pet type';
  static const String petSizePlaceholder = 'Select pet size';
  static const String breed = 'Breed (Optional)';
  static const String breedPlaceholder = 'Enter breed';
  static const String savePet = 'Save Pet';
  static const String petAddedSuccess = 'Pet added successfully!';
  static const String petUpdatedSuccess = 'Pet updated successfully!';
  static const String petDeletedSuccess = 'Pet deleted successfully!';

  // Edit Profile Strings
  static const String updateProfile = 'Update Profile';
  static const String name = 'Name';
  static const String namePlaceholder = 'Enter your name';
  static const String phoneNumber = 'Phone Number';
  static const String phoneNumberPlaceholder = 'Enter phone number';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';

  // Pet Types and Sizes
  static const String dog = 'Dog';
  static const String cat = 'Cat';
  static const String smallSize = 'Small';
  static const String mediumSize = 'Medium';
  static const String largeSize = 'Large';

  // Installer Management Screen Strings
  static const String thisMonth = 'This Month';
  static const String completedJobs = 'Completed';
  static const String inProgress = 'In Progress';
  static const String earned = 'Earned';
  static const String assigned = 'Assigned';
  static const String bids = 'Bids';

  // Management Details Screen Strings
  static const String jobNumber = 'Job #';
  static const String acceptedAsIs = 'Accepted As Is';
  static const String adjustYourBid = 'Adjust Your Bid';
  static const String jobDetails = 'Job Details';
  static const String location = 'Location';
  static const String petDoorType = 'Pet Door';
  static const String installationType = 'Installation Type';
  static const String adminsEstimatedPrice = "Admin's Estimated Price";
  static const String jobNotes = 'Job Notes';
  static const String sitePhotos = 'Site Photos & Documents';
  static const String wallInstallation = 'Wall Installation';
  static const String doorInstallationType = 'Door Installation';
  static const String glassInstallation = 'Glass Installation';

  // Adjust Bid Dialog Strings
  static const String yourProposedPrice = 'Your Proposed Price';
  static const String adminEstimate = "Admin's Estimate";
  static const String reasonForAdjustment = 'Reason for Adjustment (Optional)';
  static const String cancel = 'Cancel';
  static const String submitBid = 'Submit Bid';
  static const String enterYourProposedPrice = 'Enter your proposed price';
  static const String enterReason = 'Enter reason for adjustment';
  static const String bidSubmittedSuccess = 'Bid submitted successfully!';
  static const String bidSubmitError = 'Failed to submit bid';

  // Installer Settings Screen Strings
  static const String dashboard = 'Dashboard';
  static const String realTimeScreeningProgramManagement =
      'Real-time screening program management and compliance';
  static const String manageYourAccountAndPreferences =
      'Manage your account and preferences';

  // Admin Home Screen Strings
  static const String dashboardSubtitle =
      'Real-time screening program management and compliance';
  static const String welcomeBackExclamation = 'Welcome Back!';
  static const String businessOverview = "Here's your business overview";
  static const String newJobOffers = 'New Job Offers';
  static const String jobsAssigned = 'Jobs Assigned';
  static const String followUpsDue = 'Follow-ups Due';
  static const String createNewJob = 'Create New Job';
  static const String createServiceArea = 'Create Service Area';
  static const String recentJobs = 'Recent Jobs';
  static const String viewAll = 'View All';
  static const String showLess = 'Show Less';
  static const String recentActivity = 'Recent Activity';
  static const String createServiceAreaTitle = 'Create Service Area';
  static const String serviceAreaName = 'Service Area Name';
  static const String enterServiceAreaName = 'Enter service area name';
  static const String serviceAreaCreatedSuccessfully =
      'Service area created successfully!';
  static const String currentServiceAreas = 'Current Service Areas';

  // Profile Information Section
  static const String profileInformation = 'Profile Information';
  static const String changePhoto = 'Change Photo';
  static const String emailAddress = 'Email Address';
  static const String saveProfileChanges = 'Save Profile Changes';

  // Services Area Section
  static const String servicesArea = 'Services area';
  static const String portlandMetro = 'Portland Metro';
  static const String beaverton = 'Beaverton';
  static const String hillsboro = 'Hillsboro';
  static const String gresham = 'Gresham';
  static const String tigard = 'Tigard';
  static const String updateServiceArea = 'Update Service Area';

  // Availability Section
  static const String availability = 'Availability';
  static const String availableForNewJobs = 'Available for New Jobs';
  static const String turnOffIfNotTakingNewJobs =
      "Turn off if you're not taking new jobs";
  static const String availableHoursPerWeek = 'Available Hours per Week';
  static const String updateAvailability = 'Update Availability';

  // Payment Information Section
  static const String paymentInformation = 'Payment Information';
  static const String bankName = 'Bank Name';
  static const String accountNumber = 'Account Number';
  static const String routingNumber = 'Routing Number';
  static const String updatePaymentInfo = 'Update Payment Info';

  // Notifications Section
  static const String emailNotifications = 'Email Notifications';
  static const String receiveUpdatesViaEmail = 'Receive updates via email';
  static const String pushNotifications = 'Push Notifications';
  static const String receivePushNotifications = 'Receive push notifications';
  static const String openNotificationSettings = 'Open Notification Settings';

  // Security Section
  static const String security = 'Security';
  static const String changePassword = 'Change Password';
  static const String enableTwoFactorAuthentication =
      'Enable Two-Factor Authentication';
  static const String logout = 'Logout';

  // Create New Job Bottom Sheet Strings
  static const String customerAndPetDetails = 'Customer & Pet Details';
  static const String customerName = 'Customer Name';
  static const String phone = 'Phone';
  static const String installationAddress = 'Installation Address';
  static const String petType = 'Pet Type';
  static const String petSize = 'Pet Size';
  static const String nextPetDoorSelection = 'Next Pet Door Selection';

  static const String petDoorSelection = 'Pet Door Selection';
  static const String doorModel = 'Door Model';
  static const String nextPricing = 'Next: Pricing';
  static const String nextAssign = 'Next: Assign';
  static const String pricingAndSitePhotos = 'Pricing & Site Photos';
  static const String estimatedLaborPrice = 'Installer Price';
  static const String uploadPhotosOfInstallationSite =
      'Upload photos or documents of the installation site';
  static const String upload = 'Upload';
  static const String imagesUploaded = '0 / 10 images uploaded';

  static const String selectInstallers = 'Select Installers';
  static const String createJob = 'Create Job';

  // Installer Names (Sample Data)
  static const String johnSmith = 'John Smith';
  static const String mariaGarcia = 'Maria Garcia';
  static const String davidLee = 'David Lee';
  static const String seattleArea = 'Seattle Area';

  // Review Card Strings
  static const String rating = 'Rate your installer 1-5 stars.';
  static const String rateYourExperience =
      'Rate your experience with the installer';
  static const String yourReview = 'Your Review';
  static const String reviewPlaceholder =
      'Share your experience with the installation...';
  static const String submitReview = 'Submit Review';
  static const String reviewSubmittedSuccess = 'Thank you for your feedback!';
  static const String reviewSubmitError = 'Failed to submit review';
  static const String tapToRate = 'Tap to rate';
  static const String customerSatisfaction = 'Customer Satisfaction';
  static const String selectOption = 'Select';
  static const String pleaseSelectSatisfaction =
      'Please select customer satisfaction';
  static const String saveFeedback = 'Save Feedback';

  // Rating Questions
  static const String selectQuestion = 'Select a question to rate';
  static const String questionInstallerOnTime = 'Was the installer on time?';
  static const String questionInstallerOrganized =
      'Was the installer organized and have all his tools?';
  static const String questionInstallerCleanup =
      'Did the installer clean up after the job was finished?';
  static const String questionFinishedProductAcceptable =
      'Was the finished product acceptable?';
  static const String rateAllQuestions = 'Please rate all questions';
  static const String pleaseEnterReviewNote = 'Please write your review note';
  static const String averageRating = 'Average Rating';
}
