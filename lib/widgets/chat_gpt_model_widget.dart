import 'package:chatgpt/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openai_api/openai_api.dart';

class GptModelWidget extends HookWidget {
  final Function(String model)? onModelChanged;
  const GptModelWidget({
    super.key,
    required this.active,
    this.onModelChanged,
  });

  final String? active;

  @override
  Widget build(BuildContext context) {
    final state = useState<String>(Models.gpt3_5Turbo);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppIntl.of(context).modelSelectTitle),
        active == null
            ? DropdownButton<String>(
                items: [Models.gpt3_5Turbo, Models.gpt4].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.label),
                  );
                }).toList(),
                value: state.value,
                onChanged: (String? item) {
                  if (item == null) return;
                  state.value = item;
                  onModelChanged?.call(item);
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(active?.label ?? ""),
              ),
      ],
    );
  }
}

extension on String {
  String get label {
    switch (this) {
      case Models.gpt3_5Turbo:
        return 'GPT-3.5';
      case Models.gpt4:
        return 'GPT-4';
      default:
        return this;
    }
  }
}

extension ModelString on String {
  String toModel() {
    return this;
  }
}
