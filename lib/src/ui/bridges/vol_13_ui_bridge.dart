import "../../core/content/vol_13/vol_13_discourse.dart";
import "../../core/content/vol_13/vol_13_architecture_units.dart";
class Vol13UIBridge { static const int volume = 13, startTaskId = 1911, endTaskId = 1940; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol13SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
