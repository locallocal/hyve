import 'package:stars/domain/models/models.dart';

abstract interface class SkillEcosystemRepository {
  Future<SkillOrganizationPolicy> getOrganizationPolicy();

  Future<void> saveOrganizationPolicy(SkillOrganizationPolicy policy);

  Future<List<SkillPublisher>> getPublishers();

  Future<SkillPublisher?> getPublisher(String publisherId);

  Future<void> savePublisher(SkillPublisher publisher);

  Future<List<SkillCatalogSource>> getCatalogs();

  Future<void> saveCatalog(SkillCatalogSource catalog);

  Future<void> setSkillUpdatePolicy(String skillId, SkillUpdatePolicy policy);

  Future<SkillScriptGrant?> getScriptGrant(String skillId);

  Future<void> saveScriptGrant(SkillScriptGrant grant);

  Future<void> deleteScriptGrant(String skillId);

  Future<void> appendComplianceEvent(SkillComplianceEvent event);

  Future<List<SkillComplianceEvent>> getComplianceEvents({
    String? skillId,
    int limit = 100,
  });
}
