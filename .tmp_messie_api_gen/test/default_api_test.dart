import 'package:test/test.dart';
import 'package:messie_api/messie_api.dart';


/// tests for DefaultApi
void main() {
  final instance = MessieApi().getDefaultApi();

  group(DefaultApi, () {
    // Add a collaborator to a todo list
    //
    //Future addCollaborator(String listId, NewCollaborator newCollaborator) async
    test('test addCollaborator', () async {
      // TODO
    });

    // Get available login flows for a provider
    //
    //Future<BridgeLoginFlowsResponse> bridgeGetLoginFlows(String provider) async
    test('test bridgeGetLoginFlows', () async {
      // TODO
    });

    // Log out a specific login or all
    //
    //Future bridgeLogout(String loginId, String provider) async
    test('test bridgeLogout', () async {
      // TODO
    });

    // Start a login process for a provider
    //
    //Future<BridgeLoginStep> bridgeStartLogin(String flow, String provider) async
    test('test bridgeStartLogin', () async {
      // TODO
    });

    // Submit a login step
    //
    //Future<BridgeLoginStep> bridgeSubmitLoginStep(String processId, String stepId, String action, String provider, { BridgeSubmitLoginStepRequest bridgeSubmitLoginStepRequest }) async
    test('test bridgeSubmitLoginStep', () async {
      // TODO
    });

    // Get provider-specific whoami with logins
    //
    //Future<BridgeWhoamiResponse> bridgeWhoami(String provider) async
    test('test bridgeWhoami', () async {
      // TODO
    });

    // Add a linked ICS calendar source
    //
    //Future<CalendarImportResponse> createLinkedCalendarSource(NewCalendarLinkSource newCalendarLinkSource) async
    test('test createLinkedCalendarSource', () async {
      // TODO
    });

    // Create a new todo item in a list
    //
    //Future<TodoItem> createTodoItem(String listId, NewTodoItem newTodoItem) async
    test('test createTodoItem', () async {
      // TODO
    });

    // Create a new todo list
    //
    //Future<TodoList> createTodoList(NewTodoList newTodoList) async
    test('test createTodoList', () async {
      // TODO
    });

    // Delete a calendar source and its imported events
    //
    //Future deleteCalendarSource(String sourceId) async
    test('test deleteCalendarSource', () async {
      // TODO
    });

    // Delete a todo item
    //
    //Future deleteTodoItem(String listId, String itemId) async
    test('test deleteTodoItem', () async {
      // TODO
    });

    // Delete a todo list
    //
    //Future deleteTodoList(String listId) async
    test('test deleteTodoList', () async {
      // TODO
    });

    // List recent email headers with threading metadata
    //
    //Future<EmailRichHeadersResponse> emailHeaders(EmailLoginRequest emailLoginRequest) async
    test('test emailHeaders', () async {
      // TODO
    });

    // List recent important message headers (deprecated)
    //
    //Future emailImportant(EmailLoginRequest emailLoginRequest) async
    test('test emailImportant', () async {
      // TODO
    });

    // List recent inbox message headers
    //
    //Future<EmailMessagesResponse> emailInbox(EmailLoginRequest emailLoginRequest) async
    test('test emailInbox', () async {
      // TODO
    });

    // List recent message headers for a mailbox or flag query
    //
    //Future<EmailMessagesResponse> emailList(EmailListRequest emailListRequest) async
    test('test emailList', () async {
      // TODO
    });

    // Test email login and fetch recent message headers
    //
    //Future<EmailMessagesResponse> emailLoginTest(EmailLoginRequest emailLoginRequest) async
    test('test emailLoginTest', () async {
      // TODO
    });

    // List recent email threads
    //
    //Future<EmailMessagesResponse> emailThreads(EmailLoginRequest emailLoginRequest) async
    test('test emailThreads', () async {
      // TODO
    });

    // List bridge room to login mappings for current user
    //
    //Future<BuiltList<BridgeRoomMapping>> getBridgeRoomMappings(String provider) async
    test('test getBridgeRoomMappings', () async {
      // TODO
    });

    // Get a calendar event by ID
    //
    //Future<CalendarEvent> getCalendarEventById(String eventId) async
    test('test getCalendarEventById', () async {
      // TODO
    });

    // Get imported calendar events for the current user
    //
    //Future<BuiltList<CalendarEvent>> getCalendarEvents({ DateTime from, DateTime to, String sourceId, DateTime cursor, String direction, int limit }) async
    test('test getCalendarEvents', () async {
      // TODO
    });

    // Get a calendar source by ID
    //
    //Future<CalendarSource> getCalendarSourceById(String sourceId) async
    test('test getCalendarSourceById', () async {
      // TODO
    });

    // Get calendar sources for the current user
    //
    //Future<BuiltList<CalendarSource>> getCalendarSources() async
    test('test getCalendarSources', () async {
      // TODO
    });

    // Get collaborators for a todo list
    //
    //Future<BuiltList<CollaboratorDetail>> getCollaborators(String listId) async
    test('test getCollaborators', () async {
      // TODO
    });

    // List bridge connections for current user
    //
    // Returns zero or more connection entries per provider. Providers that support multi-account logins will return multiple items with the same `provider` value, one per account. 
    //
    //Future<BuiltList<BridgeConnection>> getConnections() async
    test('test getConnections', () async {
      // TODO
    });

    // Get a todo item by ID
    //
    //Future<TodoItem> getTodoItemById(String listId, String itemId) async
    test('test getTodoItemById', () async {
      // TODO
    });

    // Get todo items by list ID
    //
    //Future<BuiltList<TodoItem>> getTodoItemsByListId(String listId) async
    test('test getTodoItemsByListId', () async {
      // TODO
    });

    // Get a todo list by ID
    //
    //Future<TodoList> getTodoListById(String listId) async
    test('test getTodoListById', () async {
      // TODO
    });

    // Get todo lists by owner ID
    //
    //Future<BuiltList<TodoList>> getTodoListsByUserId(String userId) async
    test('test getTodoListsByUserId', () async {
      // TODO
    });

    // Get upcoming imported calendar events for the current user
    //
    //Future<BuiltList<CalendarEvent>> getUpcomingCalendarEvents({ int limit }) async
    test('test getUpcomingCalendarEvents', () async {
      // TODO
    });

    // Get user by Matrix ID
    //
    //Future<User> getUserByMatrixId(String matrixId) async
    test('test getUserByMatrixId', () async {
      // TODO
    });

    // Import a calendar source from an uploaded ICS file
    //
    //Future<CalendarImportResponse> importCalendarSource(MultipartFile file, String category, { String displayName }) async
    test('test importCalendarSource', () async {
      // TODO
    });

    // Authenticate using Matrix OpenID
    //
    //Future<MatrixAuthResponse> postMatrixAuth(MatrixOpenIDRequest matrixOpenIDRequest) async
    test('test postMatrixAuth', () async {
      // TODO
    });

    // Refresh a linked calendar source
    //
    //Future<CalendarImportResponse> refreshCalendarSource(String sourceId) async
    test('test refreshCalendarSource', () async {
      // TODO
    });

    // Remove a collaborator from a todo list
    //
    //Future removeCollaborator(String listId, String userId) async
    test('test removeCollaborator', () async {
      // TODO
    });

    // Rename a calendar source
    //
    //Future<CalendarSource> updateCalendarSource(String sourceId, UpdateCalendarSource updateCalendarSource) async
    test('test updateCalendarSource', () async {
      // TODO
    });

    // Update a todo item
    //
    //Future<TodoItem> updateTodoItem(String listId, String itemId, UpdateTodoItem updateTodoItem) async
    test('test updateTodoItem', () async {
      // TODO
    });

    // Update a todo list
    //
    //Future<TodoList> updateTodoList(String listId, UpdateTodoList updateTodoList) async
    test('test updateTodoList', () async {
      // TODO
    });

  });
}
