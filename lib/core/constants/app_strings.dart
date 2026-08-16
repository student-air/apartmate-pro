/// Centralized user-facing copy. Keeps text out of widgets and ready
/// for future localization (l10n) without touching UI code.
class AppStrings {
  AppStrings._();

  // App
  static const appName = 'Apart Mate Pro';
  static const appTagline = 'Management at Your Fingertips';
  static const tapToContinue = 'Tap to continue';
  static const appVersion = 'v1.0.0';

  // Auth - Login
  static const welcomeBack = 'Welcome Back';
  static const signInSubtitle = 'Sign in to manage your society';
  static const username = 'Username';
  static const usernameHint = 'Enter your username';
  static const password = 'Password';
  static const passwordHint = 'Enter your password';
  static const forgotPassword = 'Forgot Password?';
  static const login = 'Login';
  static const or = 'OR';
  static const continueWithGoogle = 'Continue with Google';
  static const continueWithApple = 'Continue with Apple';
  static const noAccount = "Don't have an account? ";
  static const signUp = 'Sign Up';

  // Auth - Signup
  static const createAccount = 'Create Account';
  static const signUpSubtitle = 'Join ApartMate as a society owner';
  static const fullName = 'Full Name';
  static const fullNameHint = 'e.g. John Doe';
  static const email = 'Email';
  static const emailHint = 'Enter your email';
  static const phoneNumber = 'Phone Number';
  static const phoneHint = '+92 300 1234567';
  static const createPasswordHint = 'Create a strong password';
  static const confirmPassword = 'Confirm Password';
  static const confirmPasswordHint = 'Re-enter your password';
  static const register = 'Register';
  static const alreadyHaveAccount = 'Already have an account? ';

  // Society register
  static const registerSociety = 'Register Society';
  static const societyName = 'Society Name';
  static const societyNameHint = 'e.g. Housing Society';
  static const ownerName = 'Owner Name';
  static const ownerNameHint = 'e.g. John Doe';
  static const address = 'Address';
  static const addressHint = 'Enter the society address';
  static const city = 'City';
  static const cityHint = 'Select city';
  static const country = 'Country';
  static const countryHint = 'Select country';
  static const contactNumber = 'Contact Number';
  static const contactNumberHint = '+92 300 1234567';
  static const descriptionOptional = 'Description (Optional)';
  static const descriptionHint = 'Brief description about the society...';
  static const submitRegistration = 'Submit Registration';
  
  // Society register - Registration status
  static const registrationSubmitted = 'Registration Submitted!';
  static const registrationSubmittedDesc = 'Your request has been sent. You will be notified via SMS and email once approved.';
  static const status = 'Status';
  static const pendingReview = 'PENDING REVIEW';
  static const date = 'Date';
  static const continueSetup = 'Continue Setup';


  // Society register
  static const societyBuildings = 'Society Buildings';
  static const noBuildingsAdded = 'No Buildings Added';
  static const noBuildingsHint = 'Click the button below to add your first building.';
  static const addBuilding = 'Add Building';
  static const buildingName = 'Building Name';
  static const buildingNameHint = 'e.g. Building A, Tower 1, Block North…';
  static const saveBuilding = 'Save Building';
  static const continueToStaffSetup = 'Save and Continue';
  static const detailsConfigured = '✓ Details configured';
  static const tapToAddDetails = 'Tap to add details';
  static const buildingComplete = 'Complete';
  static const buildingInProgress = 'In progress';

  // Building details
  static const buildingConfiguration = 'Building Configuration';
  static const structure = 'Structure';
  static const totalFloors = 'Total Floors';
  static const totalFloorsDesc = 'Number of floors in building';
  static const flatsPerFloor = 'Flats per Floor';
  static const flatsPerFloorDesc = 'Apartments on each level';
  static const totalApartments = 'Total Apartments';
  static const flatTypes = 'Flat Types';
  static const parking = 'Parking';
  static const dedicatedParking = 'Dedicated Parking';
  static const dedicatedParkingDesc = 'Resident parking available';
  static const parkingSlots = 'Parking Slots';
  static const parkingSlotsDesc = 'Total available spots';
  static const amenities = 'Amenities';
  static const elevatorLift = 'Elevator / Lift';
  static const elevatorLiftDesc = 'Passenger lift available';
  static const saveBuildingDetails = 'Save Building Details';
  // Staff management
  static const managementStaff = 'Staff Managment';
  static const noStaffAdded = 'No Staff Added Yet';
  static const noStaffHint = 'Click the button below to add staff members.';
  static const addStaff = 'Add Staff';
  static const addStaffMember = 'Add Staff Member';
  static const cnic = 'CNIC';
  static const cnicHint = 'e.g. 35202-1234567-8';
  static const role = 'Role';
  static const shift = 'Shift';
  static const saveStaffMember = 'Save Staff Member';
  static const saveAndGoToDashboard = 'Save & Go to Dashboard';

  static const flatNumberHint = 'e.g. E-101, A-202, A-1, B-2…';
}
