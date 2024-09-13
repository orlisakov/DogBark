// ignore_for_file: prefer_const_declarations, prefer_interpolation_to_compose_strings, prefer_function_declarations_over_variables

// cmd -> ipconfig
final url = 'http://192.168.70.1:3000/';
//final url = 'http://192.168.70.1:3000/';
//---------------------------------------------------------
final registeration = url + "registeration";
final login = url + 'login';
//---------------------- owner ---------------------------
final addDogProfile = url + 'dogProfile';
final getOwnerById = url + 'getOwnerById';
final dogProfileList = url + 'getDogProfileList';
final deleteDogProfile = url + 'deleteDogProfile';
final updateDogProfile = url + 'updateDogProfile';
final getDogProfileById = url + 'getDogProfileById';
//--------------------- trainer ---------------------------
final getTrainerById = url + 'getTrainerById';
final aaddTrainerProfile = url + 'trainerProfile';
final trainerProfileList = url + 'getTrainerProfileList';
final deleteTrainerProfile = url + 'deleteTrainerProfile';
final updateTrainerProfile = url + 'updateTrainerProfile';
final getTrainerProfileById = url + 'getTrainerProfileById';
final getTrainingRequestsExcludingTrainer = url + 'requests/exclude';
final requestsResultsById = url + 'requestsResultsById';
final getDogProfileByOwnerId = url + 'getDogProfileByOwnerId';
final getDogProfileByDogId = url + 'getDogProfileByDogId';

final searchTrainersByArea = url + 'searchTrainersByArea';
final allTrainers = url + 'allTrainers';
final createGeneralTrainingRequests = url + 'createGeneralTrainingRequests';
final deleteGeneralTrainingRequest = url + 'deleteGeneralTrainingRequest';
//---------------------------------------------------------
final requestApprove = url + 'requestApprove';
final ownerMessages = url + 'ownerMessages';
final deleteRequest = url + 'deleteRequest';
final getApprovedProcesses = url + 'getApprovedProcesses';
final getOwnerApprovedProcesses = url + 'getOwnerApprovedProcesses';
final getMessagesForUser = url + 'getMessagesForUser';

final trainerMessages = url + 'trainerMessages';
final getMessagesForTrainer = url + 'getMessagesForTrainer';

//-------------------------------------------------------------
final getTasksByDogId = url + 'getTasksByDogId';
final createNewTask = url + 'createNewTask';
final updateTaskDogStatus = url + 'updateTaskDogStatus';
final getTasksByOwnerId = url + 'getTasksByOwnerId';

//-------------------------------------------------------------
final createMessage = url + 'createMessage';
final getMessagesByChatId = url + 'getMessagesByChatId';
final uploadMediaUrl = url + "uploadMedia";

//-------------------------------------------------------------
final sendMessageAdminToUser = url + 'sendMessageAdminToUser';
final deleteUserByAdmin = url + 'deleteUserByAdmin';
final getTrainers = url + 'getTrainers';
final getOwners = url + 'getOwners';

//-----------------------------------------------------------
final sendMessageUserToAdmin = url + "sendMessageUserToAdmin";

final getTrainerProfileByDogId = url + "getTrainerProfileByDogId";
final checkIfWorkingTogether = url + "checkIfWorkingTogether";

//--------------------------------------------------------------
final createRecommendation = url + "createRecommendation";
final getRecommendations = url + "getRecommendations";

final getTrainerRecommendations = url + "getTrainerRecommendations";

final checkIfWorkingTogetherTrainerAndOwner =
    url + "checkIfWorkingTogetherTrainerAndOwner";
//--------------------------------------------------------------

// Schedule-related endpoints
final createOrUpdateSchedule = url + "createOrUpdateSchedule";
final getScheduleByTutorId = url + "getScheduleByTutorId";
final makeAppointment = url + "makeAppointment";
final getAppointmentsByOwnerId = url + "getAppointmentsByOwnerId";
final cancelAppointment = url + "cancelAppointment";
//--------------------------------------------------------------

final createPost = url + "createPost";
final getPosts = url + "getPosts";
final getTrainerProfilePicture = url + "getTrainerProfilePicture";
