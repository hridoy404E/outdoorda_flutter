import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/models/pet_model.dart';

class CustomerPetApiService {
  CustomerPetApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<Pet>> fetchCustomerPets({required String authorization}) async {
    AppLoggerHelper.info('CustomerPetApiService: fetching pets');

    final response = await _networkCaller.getRequest(
      ApiEndpoints.customerPets,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'CustomerPetApiService.fetchCustomerPets: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.isSuccess &&
        response.responseData is Map<String, dynamic> &&
        response.responseData['pets'] is List) {
      return (response.responseData['pets'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Pet.fromJson)
          .toList();
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to load pets',
    );
  }

  Future<void> createPet({
    required String authorization,
    required String name,
    required String type,
    required String size,
    String? breed,
  }) async {
    AppLoggerHelper.info('CustomerPetApiService: creating pet');

    final response = await _networkCaller.postRequest(
      ApiEndpoints.customerPets,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: _buildPetPayload(name: name, type: type, size: size, breed: breed),
    );

    AppLoggerHelper.debug(
      'CustomerPetApiService.createPet: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.isSuccess) return;

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to create pet',
    );
  }

  Future<void> updatePet({
    required String authorization,
    required String petId,
    required String name,
    required String type,
    required String size,
    String? breed,
  }) async {
    AppLoggerHelper.info('CustomerPetApiService: updating pet $petId');

    final response = await _networkCaller.putRequest(
      _buildPetDetailsEndpoint(petId),
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: _buildPetPayload(name: name, type: type, size: size, breed: breed),
    );

    AppLoggerHelper.debug(
      'CustomerPetApiService.updatePet: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.isSuccess) return;

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to update pet',
    );
  }

  Future<void> deletePet({
    required String authorization,
    required String petId,
  }) async {
    AppLoggerHelper.info('CustomerPetApiService: deleting pet $petId');

    final response = await _networkCaller.deleteRequest(
      _buildPetDetailsEndpoint(petId),
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'CustomerPetApiService.deletePet: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.isSuccess) return;

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to delete pet',
    );
  }

  Map<String, dynamic> _buildPetPayload({
    required String name,
    required String type,
    required String size,
    String? breed,
  }) {
    return {
      'name': name.trim(),
      'type': type.trim(),
      'size': size.trim(),
      'breed': breed?.trim() ?? '',
    };
  }

  String _buildPetDetailsEndpoint(String petId) {
    final cleanedId = petId.trim();
    if (cleanedId.isEmpty) {
      throw Exception('Invalid pet id');
    }
    return '${ApiEndpoints.customerPets}$cleanedId/';
  }
}
