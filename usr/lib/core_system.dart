import 'dart:math';

enum AppState {
  waiting,
  initializing,
  waitingForAbility,
  confirming,
  running,
  error,
}

class SystemIdentity {
  final String id;
  SystemIdentity(this.id);
}

class SystemMemory {
  List<String> _storage = [];

  void save(String data) {
    _storage.add(data);
  }

  List<String> load() {
    return _storage;
  }
}

class DecisionEngine {
  String evaluate(String input, List<String> context) {
    // Simulated decision logic
    final responses = [
      "認識しました。",
      "処理を続行します。",
      "その入力には対応可能なデータがありません。",
      "システム状態は正常です。",
      "対象を分析中...",
      "了解。"
    ];
    final random = Random();
    return responses[random.nextInt(responses.length)] + " (入力: $input)";
  }
}

class AbilityPackage {
  final String id;
  final String name;
  final String definition;
  final int priority;
  final String permission;

  AbilityPackage({
    required this.id,
    required this.name,
    required this.definition,
    required this.priority,
    required this.permission,
  });
}

class AbilityManager {
  final Map<String, AbilityPackage> _abilities = {};

  void store(AbilityPackage pkg) {
    _abilities[pkg.id] = pkg;
  }

  AbilityPackage? load(String id) {
    return _abilities[id];
  }
}

class CoreSystem {
  SystemIdentity? identity;
  SystemMemory? memory;
  DecisionEngine? decision;
  AbilityManager? abilityManager;

  String systemState = "OFF";

  Future<void> coreInit() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate work
    identity = SystemIdentity(_generateId());
    memory = SystemMemory();
    decision = DecisionEngine();
    abilityManager = AbilityManager();
  }

  void abilityRegister({
    required String name,
    required String definition,
    required int priority,
    required String permission,
  }) {
    final pkg = AbilityPackage(
      id: _generateId(),
      name: name,
      definition: definition,
      priority: priority,
      permission: permission,
    );
    abilityManager?.store(pkg);
  }

  bool systemConfirm() {
    if (identity != null &&
        memory != null &&
        decision != null &&
        abilityManager != null) {
      systemState = "LOCKED";
      return true;
    } else {
      systemState = "ERROR";
      return false;
    }
  }

  String decisionProcess(String input) {
    if (memory == null || decision == null) return "Error: Core not initialized";
    final context = memory!.load();
    final result = decision!.evaluate(input, context);
    return result;
  }

  void memoryStore(String data) {
    memory?.save(data);
  }

  List<String> memoryLoad() {
    return memory?.load() ?? [];
  }

  String abilityCall(String abilityId) {
    final ability = abilityManager?.load(abilityId);
    return ability?.definition ?? "Ability not found";
  }

  void voiceOutput(String text) {
    // Process with Voice_Model
    // Output Audio
    print("Voice Output: \$text");
  }

  String _generateId() {
    final random = Random();
    return List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join();
  }
}
