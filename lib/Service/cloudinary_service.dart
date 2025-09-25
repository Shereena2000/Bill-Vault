import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
 
  static const String cloudName = 'dvcodgbkd';
  static const String apiKey = '692484724374318';
  static const String apiSecret = 'hIZ6N5OjvIFXks9wWAAcveYA8v8';
  static const String uploadPreset = 'bill_vault_preset'; 

  static Future<String> uploadImage(File imageFile, String productId) async {
    try {
      if (uploadPreset.isNotEmpty) {
        return await _uploadWithPreset(imageFile, productId);
      } else {
        
        return await _uploadSigned(imageFile, productId);
      }
    } catch (e) {
      throw Exception('Failed to upload to Cloudinary: $e');
    }
  }

  static Future<String> _uploadWithPreset(File imageFile, String productId) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    
    var request = http.MultipartRequest('POST', url);
    
    request.fields['upload_preset'] = uploadPreset;
    request.fields['folder'] = 'bill_vault/bills';
    request.fields['public_id'] = 'bill_${productId}_${DateTime.now().millisecondsSinceEpoch}';
    request.fields['resource_type'] = 'image';
    
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    
    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(responseString);
      return jsonResponse['secure_url'];
    } else {
      throw Exception('Upload failed: $responseString');
    }
  }

  static Future<String> _uploadSigned(File imageFile, String productId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final publicId = 'bill_${productId}_$timestamp';
    
    final params = {
      'timestamp': timestamp,
      'public_id': publicId,
      'folder': 'bill_vault/bills',
    };
    
    final signature = _generateSignature(params, apiSecret);
    
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    
    var request = http.MultipartRequest('POST', url);
    
    request.fields['api_key'] = apiKey;
    request.fields['timestamp'] = timestamp;
    request.fields['signature'] = signature;
    request.fields['public_id'] = publicId;
    request.fields['folder'] = 'bill_vault/bills';
    
    // Add the file
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    
    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(responseString);
      return jsonResponse['secure_url'];
    } else {
      throw Exception('Upload failed: $responseString');
    }
  }

  // Generate signature for signed uploads
  static String _generateSignature(Map<String, String> params, String apiSecret) {
    var sortedParams = Map.fromEntries(
        params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    
    String stringToSign = sortedParams.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    
    stringToSign += apiSecret;
    
    var bytes = utf8.encode(stringToSign);
    var digest = sha1.convert(bytes);
    
    return digest.toString();
  }

  static Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      final params = {
        'timestamp': timestamp,
        'public_id': publicId,
      };
      
      final signature = _generateSignature(params, apiSecret);
      
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');
      
      final response = await http.post(
        url,
        body: {
          'api_key': apiKey,
          'timestamp': timestamp,
          'signature': signature,
          'public_id': publicId,
        },
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['result'] == 'ok';
      }
      
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Get optimized image URL
  static String getOptimizedImageUrl(String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    if (!originalUrl.contains('cloudinary.com')) return originalUrl;
    
    // Extract public ID from URL
    final uri = Uri.parse(originalUrl);
    final pathSegments = uri.pathSegments;
    
    // Find the version and public ID
    int uploadIndex = pathSegments.indexOf('upload');
    if (uploadIndex == -1) return originalUrl;
    
    List<String> transformations = [];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    
    String transformationString = transformations.join(',');
    
    // Rebuild URL with transformations
    List<String> newPathSegments = List.from(pathSegments);
    newPathSegments.insert(uploadIndex + 1, transformationString);
    
    return uri.replace(pathSegments: newPathSegments).toString();
  }
}
