import 'package:fluffychat/pages/messie_auth/sign_in/view_model/model/messie_public_homeserver_data.dart';
import 'package:flutter/material.dart';

class MessieSignInState {
  final MessiePublicHomeserverData? selectedHomeserver;
  final AsyncSnapshot<List<MessiePublicHomeserverData>> publicHomeservers;
  final List<MessiePublicHomeserverData> filteredPublicHomeservers;
  final AsyncSnapshot<bool> loginLoading;

  const MessieSignInState({
    this.selectedHomeserver,
    this.publicHomeservers = const AsyncSnapshot.nothing(),
    this.loginLoading = const AsyncSnapshot.nothing(),
    this.filteredPublicHomeservers = const [],
  });

  MessieSignInState copyWith({
    MessiePublicHomeserverData? selectedHomeserver,
    AsyncSnapshot<List<MessiePublicHomeserverData>>? publicHomeservers,
    AsyncSnapshot<bool>? loginLoading,
    List<MessiePublicHomeserverData>? filteredPublicHomeservers,
  }) {
    return MessieSignInState(
      selectedHomeserver: selectedHomeserver ?? this.selectedHomeserver,
      publicHomeservers: publicHomeservers ?? this.publicHomeservers,
      loginLoading: loginLoading ?? this.loginLoading,
      filteredPublicHomeservers:
          filteredPublicHomeservers ?? this.filteredPublicHomeservers,
    );
  }
}
