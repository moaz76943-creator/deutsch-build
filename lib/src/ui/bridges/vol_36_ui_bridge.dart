import "../../core/content/vol_36/vol_36_discourse.dart";
import "../../core/content/vol_36/vol_36_architecture_units.dart";
class Vol36UIBridge { static const int volume = 36, startTaskId = 2601, endTaskId = 2630; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol36SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
