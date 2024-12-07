// ignore_for_file: file_names, non_constant_identifier_names

class RespDkReceivedCode{
  final String phone_number;
  final String verify_code;

  RespDkReceivedCode({required this.phone_number,required this.verify_code});

  RespDkReceivedCode.fromJson(Map<String,dynamic> json)
    : phone_number = json['phone_number']?.toString() ?? '',
      verify_code = json['verify_code']?.toString() ?? '';

  Map<String,dynamic> toJson()=>{
    'phone_number':phone_number,
    'verify_code':verify_code
  };
}