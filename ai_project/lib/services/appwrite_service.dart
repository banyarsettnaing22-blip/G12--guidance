import 'package:appwrite/appwrite.dart';

class AppwriteService {
  late Client client;
  late Databases databases;

  // Appwrite Project ID နှင့် Database ID များ
  // (မှတ်ချက်: 'fra-' မပါသော ID အစစ်ကို သုံးရပါမည်)
  final String projectId = '6a85ef5f003d10eb304d';
  final String databaseId = '6a85f0a7003381a6ba96';
  final String collectionId = 'profiles';

  AppwriteService() {
    client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Appwrite Cloud Endpoint
        .setProject(projectId);
    databases = Databases(client);
  }

  // Username သို့မဟုတ် Email နှင့် စကားဝှက်ဖြင့် စစ်ဆေးမည့် Function
  Future<bool> loginPaidUser(String loginId, String password) async {
    try {
      print('--- 1. Sending request to Appwrite... ---');
      
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          // Username သို့မဟုတ် Email တစ်ခုခုနှင့် တူညီမှု ရှိ/မရှိ စစ်ဆေးခြင်း
          Query.or([
            Query.equal('name', loginId),
            Query.equal('email', loginId),
          ]),
          // စကားဝှက် မှန်/မမှန် စစ်ဆေးခြင်း
          Query.equal('password', password),
        ],
      );

      // Database ထဲတွင် အကောင့်တွေ့ရှိပါက
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