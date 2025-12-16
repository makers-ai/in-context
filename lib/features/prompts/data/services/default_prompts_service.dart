import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';

class DefaultPromptsService {
  static const List<Map<String, String>> defaultPromptsData = [
    {
      'name': 'Email Generator',
      'description': 'Converts context into a professional email',
      'version': '1.0.0',
      'template': '''
Based on the following context, generate a professional email:

{{CONTEXT}}

Generate a clear, concise, and professional email.
''',
    },
    {
      'name': 'To-Do List',
      'description': 'Extracts actionable tasks from context',
      'version': '1.0.0',
      'template': '''
Based on the following context, extract a prioritized to-do list:

{{CONTEXT}}

Generate a markdown checklist of concrete action items.
''',
    },
    {
      'name': 'Summary',
      'description': 'Creates a concise summary of the context',
      'version': '1.0.0',
      'template': '''
Summarize the following context in 2-3 concise paragraphs:

{{CONTEXT}}
''',
    },
    {
      'name': 'Code Agent Prompt',
      'description': 'Formats context as a detailed prompt for AI coding agents',
      'version': '1.0.0',
      'template': '''
Transform the following context into a detailed, unambiguous prompt for a code generation agent:

{{CONTEXT}}

The output should be a clear technical specification that a code agent can execute.
''',
    },
  ];

  static List<PromptEntity> getDefaultPrompts() {
    final now = DateTime.now();
    return defaultPromptsData.asMap().entries.map((entry) {
      final data = entry.value;
      return PromptEntity(
        id: 'default-${entry.key}',
        name: data['name']!,
        description: data['description']!,
        version: data['version']!,
        promptTemplate: data['template']!,
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
  }
}
