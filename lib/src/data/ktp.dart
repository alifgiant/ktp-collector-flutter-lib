class Ktp {
  final String nik;
  final String name;
  final String birthPlace;
  final String birthDate;
  final String bloodType;
  final String sex;
  final String address;
  final String rt;
  final String rw;
  final String kelurahan;
  final String kecamatan;
  final String religion;
  final String marriageStat;
  final String occupation;
  final String nationality;
  final String province;
  final String city;
  final String pictureUrl;

  const Ktp({
    required this.nik,
    required this.name,
    this.birthPlace = '',
    required this.birthDate,
    this.bloodType = '',
    required this.sex,
    this.address = '',
    this.rt = '',
    this.rw = '',
    required this.kelurahan,
    required this.kecamatan,
    required this.religion,
    required this.marriageStat,
    required this.occupation,
    this.nationality = 'WNI',
    this.province = '',
    this.city = '',
    this.pictureUrl = '',
  });

  Ktp copyWith({
    String? nik,
    String? name,
    String? birthPlace,
    String? birthDate,
    String? bloodType,
    String? sex,
    String? address,
    String? rt,
    String? rw,
    String? kelurahan,
    String? kecamatan,
    String? religion,
    String? marriageStat,
    String? occupation,
    String? nationality,
    String? province,
    String? city,
    String? pictureUrl,
  }) {
    return Ktp(
      nik: nik ?? this.nik,
      name: name ?? this.name,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      bloodType: bloodType ?? this.bloodType,
      sex: sex ?? this.sex,
      address: address ?? this.address,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      kelurahan: kelurahan ?? this.kelurahan,
      kecamatan: kecamatan ?? this.kecamatan,
      religion: religion ?? this.religion,
      marriageStat: marriageStat ?? this.marriageStat,
      occupation: occupation ?? this.occupation,
      nationality: nationality ?? this.nationality,
      province: province ?? this.province,
      city: city ?? this.city,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }

  static const Ktp empty = Ktp(
    nik: '',
    name: '',
    birthDate: '',
    sex: '',
    kelurahan: '',
    kecamatan: '',
    religion: '',
    marriageStat: '',
    occupation: '',
  );
}

List<String> blood = [
  'A',
  'B',
  'AB',
  'O',
];

List<String> religion = [
  'Islam',
  'Katolik',
  'Protestan',
  'Budha',
  'Hindu',
];

List<String> marriageStat = [
  'Kawin',
  'Belum Kawin',
  'Duda',
  'Janda',
];
