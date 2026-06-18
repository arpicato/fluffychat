# messie_api.api.DefaultApi

## Load the API package
```dart
import 'package:messie_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addCollaborator**](DefaultApi.md#addcollaborator) | **POST** /todolists/{listId}/collaborators | Add a collaborator to a todo list
[**bridgeGetLoginFlows**](DefaultApi.md#bridgegetloginflows) | **GET** /bridge/provision/v3/login/flows | Get available login flows for a provider
[**bridgeLogout**](DefaultApi.md#bridgelogout) | **POST** /bridge/provision/v3/logout/{login_id} | Log out a specific login or all
[**bridgeStartLogin**](DefaultApi.md#bridgestartlogin) | **POST** /bridge/provision/v3/login/start/{flow} | Start a login process for a provider
[**bridgeSubmitLoginStep**](DefaultApi.md#bridgesubmitloginstep) | **POST** /bridge/provision/v3/login/step/{process_id}/{step_id}/{action} | Submit a login step
[**bridgeWhoami**](DefaultApi.md#bridgewhoami) | **GET** /bridge/provision/v3/whoami | Get provider-specific whoami with logins
[**createCalendarEvent**](DefaultApi.md#createcalendarevent) | **POST** /calendar/events | Create a calendar event
[**createLinkedCalendarSource**](DefaultApi.md#createlinkedcalendarsource) | **POST** /calendar/sources/link | Add a linked ICS calendar source
[**createTodoItem**](DefaultApi.md#createtodoitem) | **POST** /todolists/{listId}/items | Create a new todo item in a list
[**createTodoList**](DefaultApi.md#createtodolist) | **POST** /todolists | Create a new todo list
[**deleteCalendarSource**](DefaultApi.md#deletecalendarsource) | **DELETE** /calendar/sources/{sourceId} | Delete a calendar source and its imported events
[**deleteTodoItem**](DefaultApi.md#deletetodoitem) | **DELETE** /todolists/{listId}/items/{itemId} | Delete a todo item
[**deleteTodoList**](DefaultApi.md#deletetodolist) | **DELETE** /todolists/{listId} | Delete a todo list
[**emailHeaders**](DefaultApi.md#emailheaders) | **POST** /email/headers | List recent email headers with threading metadata
[**emailImportant**](DefaultApi.md#emailimportant) | **POST** /email/important | List recent important message headers (deprecated)
[**emailInbox**](DefaultApi.md#emailinbox) | **POST** /email/inbox | List recent inbox message headers
[**emailList**](DefaultApi.md#emaillist) | **POST** /email/list | List recent message headers for a mailbox or flag query
[**emailLoginTest**](DefaultApi.md#emaillogintest) | **POST** /email/login-test | Test email login and fetch recent message headers
[**emailThreads**](DefaultApi.md#emailthreads) | **POST** /email/threads | List recent email threads
[**getBridgeRoomMappings**](DefaultApi.md#getbridgeroommappings) | **GET** /bridge/room-mappings | List bridge room to login mappings for current user
[**getCalendarEventById**](DefaultApi.md#getcalendareventbyid) | **GET** /calendar/events/{eventId} | Get a calendar event by ID
[**getCalendarEvents**](DefaultApi.md#getcalendarevents) | **GET** /calendar/events | Get imported calendar events for the current user
[**getCalendarSourceById**](DefaultApi.md#getcalendarsourcebyid) | **GET** /calendar/sources/{sourceId} | Get a calendar source by ID
[**getCalendarSources**](DefaultApi.md#getcalendarsources) | **GET** /calendar/sources | Get calendar sources for the current user
[**getCollaborators**](DefaultApi.md#getcollaborators) | **GET** /todolists/{listId}/collaborators | Get collaborators for a todo list
[**getConnections**](DefaultApi.md#getconnections) | **GET** /connections | List bridge connections for current user
[**getTodoItemById**](DefaultApi.md#gettodoitembyid) | **GET** /todolists/{listId}/items/{itemId} | Get a todo item by ID
[**getTodoItemsByListId**](DefaultApi.md#gettodoitemsbylistid) | **GET** /todolists/{listId}/items | Get todo items by list ID
[**getTodoListById**](DefaultApi.md#gettodolistbyid) | **GET** /todolists/{listId} | Get a todo list by ID
[**getTodoListsByUserId**](DefaultApi.md#gettodolistsbyuserid) | **GET** /todolists | Get todo lists by owner ID
[**getUpcomingCalendarEvents**](DefaultApi.md#getupcomingcalendarevents) | **GET** /calendar/upcoming | Get upcoming imported calendar events for the current user
[**getUserByMatrixId**](DefaultApi.md#getuserbymatrixid) | **GET** /users/by-matrix-id | Get user by Matrix ID
[**importCalendarSource**](DefaultApi.md#importcalendarsource) | **POST** /calendar/sources/import | Import a calendar source from an uploaded ICS file
[**postMatrixAuth**](DefaultApi.md#postmatrixauth) | **POST** /auth/matrix/openid | Authenticate using Matrix OpenID
[**refreshCalendarSource**](DefaultApi.md#refreshcalendarsource) | **POST** /calendar/sources/{sourceId}/refresh | Refresh a linked calendar source
[**removeCollaborator**](DefaultApi.md#removecollaborator) | **DELETE** /todolists/{listId}/collaborators/{userId} | Remove a collaborator from a todo list
[**setTodoListPin**](DefaultApi.md#settodolistpin) | **PUT** /todolists/{listId}/pin | Set personal pinned state for a todo list
[**updateCalendarSource**](DefaultApi.md#updatecalendarsource) | **PATCH** /calendar/sources/{sourceId} | Rename a calendar source
[**updateTodoItem**](DefaultApi.md#updatetodoitem) | **PUT** /todolists/{listId}/items/{itemId} | Update a todo item
[**updateTodoList**](DefaultApi.md#updatetodolist) | **PUT** /todolists/{listId} | Update a todo list


# **addCollaborator**
> addCollaborator(listId, newCollaborator)

Add a collaborator to a todo list

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list
final NewCollaborator newCollaborator = ; // NewCollaborator | 

try {
    api.addCollaborator(listId, newCollaborator);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->addCollaborator: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list | 
 **newCollaborator** | [**NewCollaborator**](NewCollaborator.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bridgeGetLoginFlows**
> BridgeLoginFlowsResponse bridgeGetLoginFlows(provider)

Get available login flows for a provider

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String provider = whatsapp; // String | 

try {
    final response = api.bridgeGetLoginFlows(provider);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->bridgeGetLoginFlows: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 

### Return type

[**BridgeLoginFlowsResponse**](BridgeLoginFlowsResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bridgeLogout**
> bridgeLogout(loginId, provider)

Log out a specific login or all

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String loginId = all; // String | 
final String provider = whatsapp; // String | 

try {
    api.bridgeLogout(loginId, provider);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->bridgeLogout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginId** | **String**|  | 
 **provider** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bridgeStartLogin**
> BridgeLoginStep bridgeStartLogin(flow, provider)

Start a login process for a provider

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String flow = qr; // String | 
final String provider = whatsapp; // String | 

try {
    final response = api.bridgeStartLogin(flow, provider);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->bridgeStartLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **flow** | **String**|  | 
 **provider** | **String**|  | 

### Return type

[**BridgeLoginStep**](BridgeLoginStep.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bridgeSubmitLoginStep**
> BridgeLoginStep bridgeSubmitLoginStep(processId, stepId, action, provider, bridgeSubmitLoginStepRequest)

Submit a login step

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String processId = processId_example; // String | 
final String stepId = stepId_example; // String | 
final String action = action_example; // String | 
final String provider = whatsapp; // String | 
final BridgeSubmitLoginStepRequest bridgeSubmitLoginStepRequest = ; // BridgeSubmitLoginStepRequest | 

try {
    final response = api.bridgeSubmitLoginStep(processId, stepId, action, provider, bridgeSubmitLoginStepRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->bridgeSubmitLoginStep: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **processId** | **String**|  | 
 **stepId** | **String**|  | 
 **action** | **String**|  | 
 **provider** | **String**|  | 
 **bridgeSubmitLoginStepRequest** | [**BridgeSubmitLoginStepRequest**](BridgeSubmitLoginStepRequest.md)|  | [optional] 

### Return type

[**BridgeLoginStep**](BridgeLoginStep.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bridgeWhoami**
> BridgeWhoamiResponse bridgeWhoami(provider)

Get provider-specific whoami with logins

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String provider = whatsapp; // String | 

try {
    final response = api.bridgeWhoami(provider);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->bridgeWhoami: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 

### Return type

[**BridgeWhoamiResponse**](BridgeWhoamiResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCalendarEvent**
> CalendarEvent createCalendarEvent(newCalendarEvent)

Create a calendar event

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final NewCalendarEvent newCalendarEvent = ; // NewCalendarEvent | 

try {
    final response = api.createCalendarEvent(newCalendarEvent);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createCalendarEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **newCalendarEvent** | [**NewCalendarEvent**](NewCalendarEvent.md)|  | 

### Return type

[**CalendarEvent**](CalendarEvent.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createLinkedCalendarSource**
> CalendarImportResponse createLinkedCalendarSource(newCalendarLinkSource)

Add a linked ICS calendar source

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final NewCalendarLinkSource newCalendarLinkSource = ; // NewCalendarLinkSource | 

try {
    final response = api.createLinkedCalendarSource(newCalendarLinkSource);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createLinkedCalendarSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **newCalendarLinkSource** | [**NewCalendarLinkSource**](NewCalendarLinkSource.md)|  | 

### Return type

[**CalendarImportResponse**](CalendarImportResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTodoItem**
> TodoItem createTodoItem(listId, newTodoItem)

Create a new todo item in a list

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list
final NewTodoItem newTodoItem = ; // NewTodoItem | 

try {
    final response = api.createTodoItem(listId, newTodoItem);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createTodoItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list | 
 **newTodoItem** | [**NewTodoItem**](NewTodoItem.md)|  | 

### Return type

[**TodoItem**](TodoItem.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTodoList**
> TodoList createTodoList(newTodoList)

Create a new todo list

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final NewTodoList newTodoList = ; // NewTodoList | 

try {
    final response = api.createTodoList(newTodoList);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createTodoList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **newTodoList** | [**NewTodoList**](NewTodoList.md)|  | 

### Return type

[**TodoList**](TodoList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteCalendarSource**
> deleteCalendarSource(sourceId)

Delete a calendar source and its imported events

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteCalendarSource(sourceId);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->deleteCalendarSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteTodoItem**
> deleteTodoItem(listId, itemId)

Delete a todo item

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list
final String itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo item to delete

try {
    api.deleteTodoItem(listId, itemId);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->deleteTodoItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list | 
 **itemId** | **String**| ID of the todo item to delete | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteTodoList**
> deleteTodoList(listId)

Delete a todo list

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list to delete

try {
    api.deleteTodoList(listId);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->deleteTodoList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list to delete | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **emailHeaders**
> EmailRichHeadersResponse emailHeaders(emailLoginRequest)

List recent email headers with threading metadata

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final EmailLoginRequest emailLoginRequest = ; // EmailLoginRequest | 

try {
    final response = api.emailHeaders(emailLoginRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->emailHeaders: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **emailLoginRequest** | [**EmailLoginRequest**](EmailLoginRequest.md)|  | 

### Return type

[**EmailRichHeadersResponse**](EmailRichHeadersResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **emailImportant**
> emailImportant(emailLoginRequest)

List recent important message headers (deprecated)

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final EmailLoginRequest emailLoginRequest = ; // EmailLoginRequest | 

try {
    api.emailImportant(emailLoginRequest);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->emailImportant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **emailLoginRequest** | [**EmailLoginRequest**](EmailLoginRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **emailInbox**
> EmailMessagesResponse emailInbox(emailLoginRequest)

List recent inbox message headers

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final EmailLoginRequest emailLoginRequest = ; // EmailLoginRequest | 

try {
    final response = api.emailInbox(emailLoginRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->emailInbox: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **emailLoginRequest** | [**EmailLoginRequest**](EmailLoginRequest.md)|  | 

### Return type

[**EmailMessagesResponse**](EmailMessagesResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **emailList**
> EmailMessagesResponse emailList(emailListRequest)

List recent message headers for a mailbox or flag query

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final EmailListRequest emailListRequest = ; // EmailListRequest | 

try {
    final response = api.emailList(emailListRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->emailList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **emailListRequest** | [**EmailListRequest**](EmailListRequest.md)|  | 

### Return type

[**EmailMessagesResponse**](EmailMessagesResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **emailLoginTest**
> EmailMessagesResponse emailLoginTest(emailLoginRequest)

Test email login and fetch recent message headers

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final EmailLoginRequest emailLoginRequest = ; // EmailLoginRequest | 

try {
    final response = api.emailLoginTest(emailLoginRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->emailLoginTest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **emailLoginRequest** | [**EmailLoginRequest**](EmailLoginRequest.md)|  | 

### Return type

[**EmailMessagesResponse**](EmailMessagesResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **emailThreads**
> EmailMessagesResponse emailThreads(emailLoginRequest)

List recent email threads

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final EmailLoginRequest emailLoginRequest = ; // EmailLoginRequest | 

try {
    final response = api.emailThreads(emailLoginRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->emailThreads: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **emailLoginRequest** | [**EmailLoginRequest**](EmailLoginRequest.md)|  | 

### Return type

[**EmailMessagesResponse**](EmailMessagesResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBridgeRoomMappings**
> BuiltList<BridgeRoomMapping> getBridgeRoomMappings(provider)

List bridge room to login mappings for current user

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String provider = whatsapp; // String | 

try {
    final response = api.getBridgeRoomMappings(provider);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getBridgeRoomMappings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 

### Return type

[**BuiltList&lt;BridgeRoomMapping&gt;**](BridgeRoomMapping.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCalendarEventById**
> CalendarEvent getCalendarEventById(eventId)

Get a calendar event by ID

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String eventId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getCalendarEventById(eventId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getCalendarEventById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **eventId** | **String**|  | 

### Return type

[**CalendarEvent**](CalendarEvent.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCalendarEvents**
> BuiltList<CalendarEvent> getCalendarEvents(from, to, sourceId, cursor, direction, limit)

Get imported calendar events for the current user

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final DateTime from = 2013-10-20T19:20:30+01:00; // DateTime | 
final DateTime to = 2013-10-20T19:20:30+01:00; // DateTime | 
final String sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final DateTime cursor = 2013-10-20T19:20:30+01:00; // DateTime | Anchor timestamp for cursor-based schedule pagination.
final String direction = direction_example; // String | Fetch events before or after the cursor.
final int limit = 56; // int | Maximum number of events to return for cursor-based queries.

try {
    final response = api.getCalendarEvents(from, to, sourceId, cursor, direction, limit);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getCalendarEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **sourceId** | **String**|  | [optional] 
 **cursor** | **DateTime**| Anchor timestamp for cursor-based schedule pagination. | [optional] 
 **direction** | **String**| Fetch events before or after the cursor. | [optional] 
 **limit** | **int**| Maximum number of events to return for cursor-based queries. | [optional] 

### Return type

[**BuiltList&lt;CalendarEvent&gt;**](CalendarEvent.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCalendarSourceById**
> CalendarSource getCalendarSourceById(sourceId)

Get a calendar source by ID

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getCalendarSourceById(sourceId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getCalendarSourceById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 

### Return type

[**CalendarSource**](CalendarSource.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCalendarSources**
> BuiltList<CalendarSource> getCalendarSources()

Get calendar sources for the current user

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();

try {
    final response = api.getCalendarSources();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getCalendarSources: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;CalendarSource&gt;**](CalendarSource.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCollaborators**
> BuiltList<CollaboratorDetail> getCollaborators(listId)

Get collaborators for a todo list

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list to retrieve collaborators for

try {
    final response = api.getCollaborators(listId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getCollaborators: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list to retrieve collaborators for | 

### Return type

[**BuiltList&lt;CollaboratorDetail&gt;**](CollaboratorDetail.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getConnections**
> BuiltList<BridgeConnection> getConnections()

List bridge connections for current user

Returns zero or more connection entries per provider. Providers that support multi-account logins will return multiple items with the same `provider` value, one per account. 

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();

try {
    final response = api.getConnections();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getConnections: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;BridgeConnection&gt;**](BridgeConnection.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTodoItemById**
> TodoItem getTodoItemById(listId, itemId)

Get a todo item by ID

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list
final String itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo item to retrieve

try {
    final response = api.getTodoItemById(listId, itemId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getTodoItemById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list | 
 **itemId** | **String**| ID of the todo item to retrieve | 

### Return type

[**TodoItem**](TodoItem.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTodoItemsByListId**
> BuiltList<TodoItem> getTodoItemsByListId(listId)

Get todo items by list ID

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list to retrieve items for

try {
    final response = api.getTodoItemsByListId(listId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getTodoItemsByListId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list to retrieve items for | 

### Return type

[**BuiltList&lt;TodoItem&gt;**](TodoItem.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTodoListById**
> TodoList getTodoListById(listId)

Get a todo list by ID

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list to retrieve

try {
    final response = api.getTodoListById(listId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getTodoListById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list to retrieve | 

### Return type

[**TodoList**](TodoList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTodoListsByUserId**
> BuiltList<TodoList> getTodoListsByUserId(userId)

Get todo lists by owner ID

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the user to retrieve todo lists for

try {
    final response = api.getTodoListsByUserId(userId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getTodoListsByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| ID of the user to retrieve todo lists for | 

### Return type

[**BuiltList&lt;TodoList&gt;**](TodoList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUpcomingCalendarEvents**
> BuiltList<CalendarEvent> getUpcomingCalendarEvents(limit)

Get upcoming imported calendar events for the current user

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final int limit = 56; // int | 

try {
    final response = api.getUpcomingCalendarEvents(limit);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getUpcomingCalendarEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] 

### Return type

[**BuiltList&lt;CalendarEvent&gt;**](CalendarEvent.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserByMatrixId**
> User getUserByMatrixId(matrixId)

Get user by Matrix ID

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String matrixId = matrixId_example; // String | Matrix user ID

try {
    final response = api.getUserByMatrixId(matrixId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getUserByMatrixId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **matrixId** | **String**| Matrix user ID | 

### Return type

[**User**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importCalendarSource**
> CalendarImportResponse importCalendarSource(file, category, displayName)

Import a calendar source from an uploaded ICS file

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | 
final String category = category_example; // String | 
final String displayName = displayName_example; // String | 

try {
    final response = api.importCalendarSource(file, category, displayName);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->importCalendarSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**|  | 
 **category** | **String**|  | 
 **displayName** | **String**|  | [optional] 

### Return type

[**CalendarImportResponse**](CalendarImportResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postMatrixAuth**
> MatrixAuthResponse postMatrixAuth(matrixOpenIDRequest)

Authenticate using Matrix OpenID

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final MatrixOpenIDRequest matrixOpenIDRequest = ; // MatrixOpenIDRequest | 

try {
    final response = api.postMatrixAuth(matrixOpenIDRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->postMatrixAuth: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **matrixOpenIDRequest** | [**MatrixOpenIDRequest**](MatrixOpenIDRequest.md)|  | 

### Return type

[**MatrixAuthResponse**](MatrixAuthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshCalendarSource**
> CalendarImportResponse refreshCalendarSource(sourceId)

Refresh a linked calendar source

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.refreshCalendarSource(sourceId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->refreshCalendarSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 

### Return type

[**CalendarImportResponse**](CalendarImportResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeCollaborator**
> removeCollaborator(listId, userId)

Remove a collaborator from a todo list

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the user to remove as collaborator

try {
    api.removeCollaborator(listId, userId);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->removeCollaborator: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list | 
 **userId** | **String**| ID of the user to remove as collaborator | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setTodoListPin**
> TodoList setTodoListPin(listId, setTodoListPin)

Set personal pinned state for a todo list

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list to pin or unpin
final SetTodoListPin setTodoListPin = ; // SetTodoListPin | 

try {
    final response = api.setTodoListPin(listId, setTodoListPin);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->setTodoListPin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list to pin or unpin | 
 **setTodoListPin** | [**SetTodoListPin**](SetTodoListPin.md)|  | 

### Return type

[**TodoList**](TodoList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateCalendarSource**
> CalendarSource updateCalendarSource(sourceId, updateCalendarSource)

Rename a calendar source

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final UpdateCalendarSource updateCalendarSource = ; // UpdateCalendarSource | 

try {
    final response = api.updateCalendarSource(sourceId, updateCalendarSource);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updateCalendarSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 
 **updateCalendarSource** | [**UpdateCalendarSource**](UpdateCalendarSource.md)|  | 

### Return type

[**CalendarSource**](CalendarSource.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTodoItem**
> TodoItem updateTodoItem(listId, itemId, updateTodoItem)

Update a todo item

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list
final String itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo item to update
final UpdateTodoItem updateTodoItem = ; // UpdateTodoItem | 

try {
    final response = api.updateTodoItem(listId, itemId, updateTodoItem);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updateTodoItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list | 
 **itemId** | **String**| ID of the todo item to update | 
 **updateTodoItem** | [**UpdateTodoItem**](UpdateTodoItem.md)|  | 

### Return type

[**TodoItem**](TodoItem.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTodoList**
> TodoList updateTodoList(listId, updateTodoList)

Update a todo list

### Example
```dart
import 'package:messie_api/api.dart';

final api = MessieApi().getDefaultApi();
final String listId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the todo list to update
final UpdateTodoList updateTodoList = ; // UpdateTodoList | 

try {
    final response = api.updateTodoList(listId, updateTodoList);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updateTodoList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listId** | **String**| ID of the todo list to update | 
 **updateTodoList** | [**UpdateTodoList**](UpdateTodoList.md)|  | 

### Return type

[**TodoList**](TodoList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

