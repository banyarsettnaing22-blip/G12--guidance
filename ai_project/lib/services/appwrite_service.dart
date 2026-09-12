import 'package:appwrite/appwrite.dart';

class AppwriteService {
  late Client client;
  late Databases databases;

  final String projectId = '6a85ef5f003d10eb304d';
  final String databaseId = '6a85f0a7003381a6ba96';
  final String collectionId = 'profiles';

  AppwriteService() {
    client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') 
        .setProject(projectId);
    databases = Databases(client);
  }

  Future<bool> loginPaidUser(String loginId, String password) async {
    try {
      print('--- 1. Sending request to Appwrite... ---');
      
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.or([
            Query.equal('name', loginId),
            Query.equal('email', loginId),
          ]),
          Query.equal('password', password),
        ],
      );

      if (response.documents.isNotEmpty) {
        final userDoc = response.documents.first.data;
        bool isPaid = userDoc['is_paid'] ?? false;
        
        if (isPaid) {
          print('--- 2. Login Success as Premium: ${userDoc['name']} ---');
          return true;
        } else {
          print('--- 2. Login Failed: Not a premium user ---');
        }
      } else {
        print('--- 2. Login Failed: Account not found ---');
      }
      return false;
    } catch (e) {
      print('--- APPWRITE ERROR: $e ---');
      return false;
    }
  }
}