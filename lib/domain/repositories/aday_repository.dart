import '../models/aday_snapshot.dart';

abstract interface class ADayRepository {
  Future<ADaySnapshot> load();

  Future<void> save(ADaySnapshot snapshot);
}
