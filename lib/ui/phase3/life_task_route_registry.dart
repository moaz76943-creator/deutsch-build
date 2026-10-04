import 'package:flutter/material.dart';

import '../../features/life_bicycle_mobility/bicycle_screen.dart';
import '../../features/life_bureaucracy/application/bureaucracy_master_orchestrator.dart';
import '../../features/life_bureaucracy/presentation/life_bureaucracy_screen.dart';
import '../../features/life_car_service/car_service_screen.dart';
import '../../features/life_career/career_screen.dart';
import '../../features/life_childcare_kindergarten/childcare_screen.dart';
import '../../features/life_clothing_alterations/clothing_master_screen.dart';
import '../../features/life_culture/application/culture_master_orchestrator.dart';
import '../../features/life_culture/presentation/life_culture_screen.dart';
import '../../features/life_cycling/cycling_screen.dart';
import '../../features/life_dentist_clinic/dentist_master_hub.dart';
import '../../features/life_dentist_clinic/dentist_master_orchestrator.dart';
import '../../features/life_diy/diy_screen.dart';
import '../../features/life_doctor_appointment/application/doctor_appointment_master_orchestrator.dart';
import '../../features/life_doctor_appointment/presentation/doctor_appointment_master_hub.dart';
import '../../features/life_driving/presentation/driving_master_screen.dart';
import '../../features/life_drogerie_market/drogerie_master_hub.dart';
import '../../features/life_drogerie_market/drogerie_master_orchestrator.dart';
import '../../features/life_education/presentation/family_education_master_screen.dart';
import '../../features/life_electronics_appliances/electronics_appliances_screen.dart';
import '../../features/life_emergency_health/emergency_health_master_hub.dart';
import '../../features/life_environment/environment_screen.dart';
import '../../features/life_furniture_home_setup/furniture_home_screen.dart';
import '../../features/life_gas_station_carwash/gas_station_carwash_screen.dart';
import '../../features/life_haircut_barbershop/presentation/haircut_master_screen.dart';
import '../../features/life_hardware_store_diy/hardware_store_master_hub.dart';
import '../../features/life_health/application/hausarzt_agent.dart';
import '../../features/life_health/application/health_master_orchestrator.dart';
import '../../features/life_health/application/pharmacy_agent.dart';
import '../../features/life_health/presentation/health_master_screen.dart';
import '../../features/life_home_services/home_services_screen.dart';
import '../../features/life_housing/presentation/housing_master_screen.dart';
import '../../features/life_intercity_train_travel/intercity_train_screen.dart';
import '../../features/life_jobcenter_employment/application/jobcenter_master_orchestrator.dart';
import '../../features/life_jobcenter_employment/presentation/life_jobcenter_employment_screen.dart';
import '../../features/life_laundry/laundry_screen.dart';
import '../../features/life_lost_found/lost_found_screen.dart';
import '../../features/life_maintenance/maintenance_master_hub.dart';
import '../../features/life_mobility/application/mobility_master_orchestrator.dart';
import '../../features/life_mobility/data/local_mobility_repository.dart';
import '../../features/life_mobility/presentation/mobility_screen.dart';
import '../../features/life_optician_glasses/optician_master_hub.dart';
import '../../features/life_optician_glasses/optician_master_orchestrator.dart';
import '../../features/life_outdoors/presentation/outdoors_master_screen.dart';
import '../../features/life_pets/pets_screen.dart';
import '../../features/life_pharmacy_medication/pharmacy_master_hub.dart';
import '../../features/life_postal_delivery/postal_screen.dart';
import '../../features/life_public_offices/public_offices_screen.dart';
import '../../features/life_rent_housing/rent_housing_screen.dart';
import '../../features/life_restaurant_dining/restaurant_screen.dart';
import '../../features/life_safety/application/official_reporting_sub_agent.dart';
import '../../features/life_safety/application/roadside_assistance_sub_agent.dart';
import '../../features/life_safety/application/safety_master_orchestrator.dart';
import '../../features/life_safety/presentation/safety_master_screen.dart';
import '../../features/life_secondhand/secondhand_screen.dart';
import '../../features/life_services/services_screen.dart';
import '../../features/life_shoe_repair_keys/shoe_repair_keys_screen.dart';
import '../../features/life_shopping/application/shopping_agents.dart';
import '../../features/life_shopping/application/shopping_master_orchestrator.dart';
import '../../features/life_shopping/presentation/shopping_master_screen.dart';
import '../../features/life_social/social_screen.dart';
import '../../features/life_sports/sports_screen.dart';
import '../../features/life_supermarket_groceries/supermarket_screen.dart';
import '../../features/life_telecom/telecom_screen.dart';
import '../../features/life_travel_agency/travel_agency_screen.dart';
import '../../features/life_utilities/utilities_screen.dart';
import '../../features/life_waste_recycling/waste_recycling_screen.dart';
import '../../features/phase3_integration/life_curriculum_catalog.dart';
import 'localized_task_route_host.dart';
import 'phase6_l10n_controller.dart';

final class LifeTaskRouteRegistry {
  LifeTaskRouteRegistry({
    LifeCurriculumCatalog? catalog,
    this.localizationController,
  })  : catalog = catalog ?? LifeCurriculumCatalog.standard(),
        _builders = _createBuilders() {
    final catalogKeys = this.catalog.links
        .map((link) => link.featureKey)
        .toSet();
    final routeKeys = _builders.keys.toSet();
    if (catalogKeys.length != 50 ||
        routeKeys.length != 50 ||
        !catalogKeys.containsAll(routeKeys) ||
        !routeKeys.containsAll(catalogKeys)) {
      throw StateError(
        'Life route registry must match the 50-entry curriculum catalog.',
      );
    }
  }

  final LifeCurriculumCatalog catalog;
  final Phase6L10nController? localizationController;
  final Map<String, WidgetBuilder> _builders;

  Set<String> get featureKeys => Set<String>.unmodifiable(_builders.keys);

  WidgetBuilder builderFor(String featureKey) {
    final builder = _builders[featureKey.trim()];
    if (builder == null) {
      throw StateError('No UI route registered for $featureKey.');
    }
    final controller = localizationController;
    if (controller == null) return builder;
    return (context) => LocalizedTaskRouteHost(
          controller: controller,
          childBuilder: builder,
        );
  }

  bool canOpen(String featureKey) =>
      _builders.containsKey(featureKey.trim());

  static Map<String, WidgetBuilder> _createBuilders() =>
      Map<String, WidgetBuilder>.unmodifiable(
        <String, WidgetBuilder>{
          'life_bicycle_mobility': (_) => BicycleMasterHub(),
          'life_bureaucracy': (_) =>
              _OwnedNotifierPage<BureaucracyMasterOrchestrator>(
                create: () => BureaucracyMasterOrchestrator(),
                builder: (orchestrator) =>
                    LifeBureaucracyScreen(orchestrator: orchestrator),
              ),
          'life_car_service': (_) => CarServiceMasterHub(),
          'life_career': (_) => CareerHubScreen(),
          'life_childcare_kindergarten': (_) =>
              ChildcareKindergartenMasterScreen(),
          'life_clothing_alterations': (_) =>
              ClothingAlterationsMasterScreen(),
          'life_culture': (_) =>
              _OwnedNotifierPage<CultureMasterOrchestrator>(
                create: () => CultureMasterOrchestrator(),
                builder: (orchestrator) =>
                    LifeCultureScreen(orchestrator: orchestrator),
              ),
          'life_cycling': (_) => CyclingMasterHub(),
          'life_dentist_clinic': (_) => DentistMasterHub(
                orchestrator: DentistMasterOrchestrator(),
              ),
          'life_diy': (_) => DiyMasterHub(),
          'life_doctor_appointment': (_) =>
              DoctorAppointmentMasterHub(
                orchestrator: DoctorAppointmentMasterOrchestrator(),
              ),
          'life_driving': (_) => DrivingMasterScreen(),
          'life_drogerie_market': (_) => DrogerieMasterHub(
                orchestrator: DrogerieMasterOrchestrator(),
              ),
          'life_education': (_) => FamilyEducationMasterScreen(),
          'life_electronics_appliances': (_) =>
              ElectronicsAppliancesMasterHub(),
          'life_emergency_health': (_) =>
              EmergencyHealthMasterHub(),
          'life_environment': (_) => EnvironmentMasterHub(),
          'life_furniture_home_setup': (_) =>
              FurnitureHomeMasterScreen(),
          'life_gas_station_carwash': (_) =>
              GasStationCarwashMasterHub(),
          'life_haircut_barbershop': (_) => HaircutMasterScreen(),
          'life_hardware_store_diy': (_) =>
              HardwareStoreMasterHub(),
          'life_health': (_) => HealthMasterScreen(
                orchestrator: HealthMasterOrchestrator(
                  pharmacy: PharmacyAgent(),
                  hausarzt: HausarztAgent(),
                ),
              ),
          'life_home_services': (_) => HomeServicesMasterHub(),
          'life_housing': (_) => HousingMasterScreen(),
          'life_intercity_train_travel': (_) =>
              IntercityTrainTravelMasterScreen(),
          'life_jobcenter_employment': (_) =>
              _OwnedNotifierPage<JobcenterMasterOrchestrator>(
                create: () => JobcenterMasterOrchestrator(),
                builder: (orchestrator) =>
                    LifeJobcenterEmploymentScreen(
                  orchestrator: orchestrator,
                ),
              ),
          'life_laundry': (_) => LaundryMasterHub(),
          'life_lost_found': (_) => LostFoundMasterHub(),
          'life_mobility': (_) =>
              _OwnedNotifierPage<MobilityMasterOrchestrator>(
                create: () => MobilityMasterOrchestrator(
                  const LocalMobilityRepository(),
                ),
                builder: (orchestrator) =>
                    MobilityScreen(orchestrator: orchestrator),
              ),
          'life_optician_glasses': (_) => OpticianMasterHub(
                orchestrator: OpticianMasterOrchestrator(),
              ),
          'life_outdoors': (_) => OutdoorsMasterScreen(),
          'life_pets': (_) => PetsMasterHub(),
          'life_pharmacy_medication': (_) => PharmacyMasterHub(),
          'life_postal_delivery': (_) => PostalDeliveryMasterHub(),
          'life_public_offices': (_) => PublicOfficesMasterHub(),
          'life_rent_housing': (_) => RentHousingMasterHub(),
          'life_restaurant_dining': (_) =>
              RestaurantDiningMasterHub(),
          'life_safety': (_) => SafetyMasterScreen(
                orchestrator: SafetyMasterOrchestrator(
                  roadsideAssistance: RoadsideAssistanceSubAgent(),
                  officialReporting: OfficialReportingSubAgent(),
                ),
              ),
          'life_secondhand': (_) => SecondhandMasterHub(),
          'life_services': (_) => ServicesMasterHubScreen(),
          'life_shoe_repair_keys': (_) =>
              ShoeRepairKeysMasterScreen(),
          'life_shopping': (_) =>
              _OwnedNotifierPage<ShoppingMasterOrchestrator>(
                create: () => ShoppingMasterOrchestrator(
                  groceryAgent: const GroceryShoppingAgent(),
                  returnWarrantyAgent:
                      const ReturnWarrantyShoppingAgent(),
                ),
                builder: (orchestrator) =>
                    ShoppingMasterScreen(orchestrator: orchestrator),
              ),
          'life_social': (_) => SocialMasterHub(),
          'life_sports': (_) => SportsMasterHub(),
          'life_supermarket_groceries': (_) =>
              SupermarketGroceriesMasterHub(),
          'life_telecom': (_) => TelecomMasterHub(),
          'life_travel_agency': (_) => TravelAgencyMasterScreen(),
          'life_utilities': (_) => UtilitiesMasterHub(),
          'life_waste_recycling': (_) =>
              WasteRecyclingMasterHub(),
          'life_maintenance': (context) => MaintenanceMasterHub(
                onOpenRepairs: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HomeServicesMasterHub(),
                  ),
                ),
                onOpenWasteSorting: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WasteRecyclingMasterHub(),
                  ),
                ),
              ),
        },
      );
}

final class _OwnedNotifierPage<T extends ChangeNotifier>
    extends StatefulWidget {
  const _OwnedNotifierPage({
    required this.create,
    required this.builder,
  });

  final T Function() create;
  final Widget Function(T notifier) builder;

  @override
  State<_OwnedNotifierPage<T>> createState() =>
      _OwnedNotifierPageState<T>();
}

final class _OwnedNotifierPageState<T extends ChangeNotifier>
    extends State<_OwnedNotifierPage<T>> {
  late final T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_notifier);
}
