import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openai_api/openai_api.dart';

class GptModelWidget extends HookWidget {
  final Function(Model model)? onModelChanged;
  const GptModelWidget({
    super.key,
    required this.active,
    this.onModelChanged,
  });

  final Model? active;

  @override
  Widget build(BuildContext context) {
    final state = useState<Model>(Model.gpt3_5Turbo);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Model: '),
        active == null
            ? DropdownButton<Model>(
                items: [Model.gpt3_5Turbo, Model.gpt4].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.label),
                  );
                }).toList(),
                value: state.value,
                onChanged: (Model? item) {
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

extension on Model {
  String get label {
    switch (this) {
      case Model.gpt3_5Turbo:
        return 'GPT-3.5';
      case Model.gpt4:
        return 'GPT-4';
      default:
        return value;
    }
  }
}

extension ModelString on String {
  Model toModel() {
    return Model.values.where((e) => e.value == this).firstOrNull ??
        Model.gpt3_5Turbo;
  }
}
