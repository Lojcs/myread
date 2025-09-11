import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helpers/extensions.dart';
import '../../settings/cubit/settings_cubit.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<StatefulWidget> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  String apiKey = "";
  bool keyInvalid = false;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text("Comicvine API key is needed"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: InputDecoration(
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            hintText: "ComicVine API key",
            hintStyle: TextStyle(fontSize: 18),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.colorScheme.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
          onChanged: (value) => setState(() => apiKey = value),
        ),
      ],
    ),
    actions: [
      if (keyInvalid)
        Text(
          "⚠️Key is invalid⚠️",
          style: context.textTheme.bodyMedium!.copyWith(color: Colors.red),
        ),
      TextButton(
        onPressed: () async {
          if (apiKey == "") {
            context.navigator.pop();
            return;
          }
          setState(() => keyInvalid = false);
          final success = await BlocProvider.of<SettingsCubit>(
            context,
            listen: false,
          ).trySetApiKey(apiKey);
          if (success) {
            if (context.mounted) {
              context.navigator.pop();
            }
          } else {
            setState(() => keyInvalid = true);
          }
        },
        child: apiKey == "" ? Text("Skip") : Text("Save"),
      ),
    ],
  );
}
