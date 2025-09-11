import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';

import '../../../core/helpers/extensions.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_sync_cubit.dart';

class SettingsSyncPage extends StatelessWidget {
  const SettingsSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final syncCubit = SettingsSyncCubit();
    return BlocProvider.value(
      value: syncCubit,
      child: Scaffold(
        appBar: AppBar(title: Text("Sync Settings")),
        body: SingleChildScrollView(
          child: Column(
            children: [
              BlocBuilder<SettingsSyncCubit, SettingsSyncState>(
                builder:
                    (context, state) => ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text(
                        state.user == null
                            ? "Add account"
                            : "Configure account",
                      ),
                      subtitle: Text("Options for account management."),
                      onTap: () {
                        syncCubit.setError();
                        showDialog(
                          fullscreenDialog: true,
                          context: context,
                          builder: (context) => AccountDialog(syncCubit),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountDialog extends StatefulWidget {
  final SettingsSyncCubit syncCubit;
  const AccountDialog(this.syncCubit, {super.key});

  @override
  State<StatefulWidget> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<AccountDialog> {
  bool keyInvalid = false;
  bool createAccount = false;

  late final User? user = widget.syncCubit.state.user;
  late String email = user?.email ?? "";
  String password = "";
  String newPassword = "";

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text("MyRead account"),
    contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 232,
          height: 58,
          child: switch (user) {
            null => Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 4),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                isSelected: [!createAccount, createAccount],
                children: [
                  SizedBox(width: 114, child: Center(child: Text("Log in"))),
                  SizedBox(width: 114, child: Center(child: Text("Sign up"))),
                ],
                onPressed: (i) => setState(() => createAccount = i == 1),
              ),
            ),
            User(:var email) => Center(
              child: Text(email!, style: context.textTheme.bodyLarge),
            ),
          },
        ),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 4),
          child: TextFormField(
            enabled: user == null,
            initialValue: email,
            decoration: InputDecoration(
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              hintText: "Email",
              hintStyle: TextStyle(fontSize: 18),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
            onChanged: (value) => setState(() => email = value),
          ),
        ),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 4),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              hintText: "Password",
              hintStyle: TextStyle(fontSize: 18),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
            onChanged: (value) => setState(() => password = value),
          ),
        ),
        if (user != null)
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 4),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: "New Password",
                hintStyle: TextStyle(fontSize: 18),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.colorScheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              onChanged: (value) => setState(() => newPassword = value),
            ),
          ),
        BlocSelector<SettingsSyncCubit, SettingsSyncState, SettingsSyncError?>(
          selector: (state) => state.error,
          bloc: widget.syncCubit,
          builder:
              (context, error) =>
                  error != null
                      ? Text(
                        error.message,
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: context.colorScheme.error,
                        ),
                      )
                      : Center(),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => context.navigator.pop(),
        child: Text("Cancel"),
      ),
      if (user != null)
        TextButton(
          onPressed:
              () => showDialog(
                context: context,
                builder: (context) => AccountRemoveDialog(widget.syncCubit),
              ),
          child: Text(
            "Remove",
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ),
      TextButton(
        onPressed: onDone(),
        child: user == null ? Text("Submit") : Text("Update"),
      ),
    ],
  );

  VoidCallback? onDone() => switch ((
    user,
    email,
    password,
    newPassword,
    createAccount,
  )) {
    (_, _, "", _, _) => null,
    (null, "", _, _, _) || (User _, _, _, "", _) => null,
    (null, var email, var password, _, false) => popOnTrueCallback(
      () => widget.syncCubit.logIn(email, password),
    ),
    (null, var email, var password, _, true) => popOnTrueCallback(
      () => widget.syncCubit.createAccount(email, password),
    ),
    (User _, _, var password, var newPassword, _) => popOnTrueCallback(
      () => widget.syncCubit.updatePassword(password, newPassword),
    ),
  };

  Future<void> Function() popOnTrueCallback(
    Future<bool> Function() computation,
  ) => () async {
    final navigator = context.navigator;
    final result = await computation();
    if (result) navigator.pop();
  };
}

class AccountRemoveDialog extends StatefulWidget {
  final SettingsSyncCubit syncCubit;
  const AccountRemoveDialog(this.syncCubit, {super.key});

  @override
  State<StatefulWidget> createState() => _AccountRemoveDialog();
}

class _AccountRemoveDialog extends State<AccountRemoveDialog> {
  String password = "";
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text("Removing account"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 4),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              hintText: "Password for deletion",
              hintStyle: TextStyle(fontSize: 18),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
            onChanged: (value) => setState(() => password = value),
          ),
        ),
        BlocSelector<SettingsSyncCubit, SettingsSyncState, SettingsSyncError?>(
          selector: (state) => state.error,
          bloc: widget.syncCubit,
          builder:
              (context, error) =>
                  error != null
                      ? Text(
                        error.message,
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: context.colorScheme.error,
                        ),
                      )
                      : Center(),
        ),
        SizedBox(
          width: 232,
          child: ToggleButtons(
            direction: Axis.vertical,
            borderRadius: BorderRadius.circular(8),
            isSelected: [true, true, false],
            // color: Colors.red,
            fillColor: Colors.red[400],
            children: [
              Text("Delete Permanently", style: context.textTheme.bodyMedium),
              Text("Sign Out", style: context.textTheme.bodyMedium),
              Text("Cancel"),
            ],
            onPressed: (i) async {
              switch (i) {
                case 0:
                  if (password != "") {
                    doublePopOnTrue(
                      () => widget.syncCubit.deleteAccount(password),
                    );
                  }
                case 1:
                  doublePopOnTrue(() => widget.syncCubit.logOut());
                case 2:
                  context.navigator.pop();
              }
            },
          ),
        ),
      ],
    ),
  );
  Future<void> doublePopOnTrue(Future<bool> Function() computation) async {
    final navigator = context.navigator;
    final result = await computation();
    if (result) {
      navigator.pop();
      navigator.pop();
    }
  }
}
