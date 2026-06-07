import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/environmental_snapshot.dart';
import 'package:green_signal/models/map_layer_data.dart';
import 'package:green_signal/services/location/location_override_store.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const email = 'user@example.com';
  const override = ResolvedLocation(
    position: LatLng(-23.55, -46.63),
    label: 'São Paulo, SP',
    neighborhood: 'São Paulo',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setOverride persists and loadForUser restores location', () async {
    final store = LocationOverrideStore();

    await store.setOverride(override, email);
    expect(store.isExploring, isTrue);
    expect(store.current?.label, 'São Paulo, SP');

    final reloaded = LocationOverrideStore();
    await reloaded.loadForUser(email);

    expect(reloaded.isExploring, isTrue);
    expect(reloaded.current?.label, override.label);
    expect(reloaded.current?.position.latitude, override.position.latitude);
  });

  test('clearOverride removes persisted location', () async {
    final store = LocationOverrideStore();
    await store.setOverride(override, email);

    await store.clearOverride(email);

    expect(store.isExploring, isFalse);
    expect(store.current, isNull);

    final reloaded = LocationOverrideStore();
    await reloaded.loadForUser(email);
    expect(reloaded.current, isNull);
  });

  test('loadForUser with null email clears current override', () async {
    final store = LocationOverrideStore();
    await store.setOverride(override, email);

    await store.loadForUser(null);

    expect(store.current, isNull);
  });

  test('keys are scoped per user email', () async {
    final store = LocationOverrideStore();
    const otherOverride = ResolvedLocation(
      position: MapLayerData.saoPauloCenter,
      label: 'Curitiba, PR',
      neighborhood: 'Curitiba',
    );

    await store.setOverride(override, email);
    await store.loadForUser('other@example.com');
    expect(store.current, isNull);

    await store.setOverride(otherOverride, 'other@example.com');
    await store.loadForUser(email);
    expect(store.current?.label, override.label);
  });
}
