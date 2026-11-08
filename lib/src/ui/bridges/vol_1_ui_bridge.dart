import "../../core/content/vol_1/vol_1_discourse.dart";
import "../../core/content/vol_1/vol_1_architecture_units.dart";
class Vol1UIBridge { static const int volume = 1, startTaskId = 1551, endTaskId = 1580; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol1SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
