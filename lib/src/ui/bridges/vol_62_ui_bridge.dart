import "../../core/content/vol_62/vol_62_discourse.dart";
import "../../core/content/vol_62/vol_62_architecture_units.dart";
class Vol62UIBridge { static const int volume = 62, startTaskId = 3381, endTaskId = 3410; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol62SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
