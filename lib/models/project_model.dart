import '../constants/strings.dart';
import '../utils/extensions.dart';

List<Project> projectsFromJson(dynamic data) {
  final projects = data["updatedProperties"];
  final List<Project> projectList =
      List<Project>.from(projects.map((x) => Project.fromJson(x)));

  projectList.sort((a, b) {
    final statusA = a.status.toLowerCase();
    final statusB = b.status.toLowerCase();
    const tr = 'trending';
    const up = 'upcoming';
    const cp = 'closed';
    if (statusA == tr) {
      return -1; // 'trending' comes before other statuses
    } else if (statusA == up && statusB != tr) {
      return -1; // 'upcoming' comes before 'completed'
    } else if (statusA == cp && statusB != tr && statusB != up) {
      return -1; // 'completed' comes last
    } else {
      return 1; // keep the order unchanged
    }
  });

  return projectList;
}

class Project {
  int id;
  String propertyName;
  String propertyAddress;
  String returns;
  String lvr;
  String term;
  double facility;
  String status;
  String desc;
  String? pds;
  String? spds;
  String? tdm;
  String? fsg;
  double pricePerShare;
  bool isDelete;
  bool isDocument;
  String? state;
  String propType;
  double firstInstallmentPrice;
  int? propVoteCount;
  double basePrice;
  String createdAt;
  String updatedAt;
  List<String> images;
  String fundTypeName;
  int fundType;
  int fundSubType;
  String minInvestment;
  String voteDescp;
  bool isVote;
  List<GeneralDocs> generalDocs;

  Project({
    required this.id,
    required this.propertyName,
    required this.propertyAddress,
    required this.returns,
    required this.lvr,
    required this.term,
    required this.facility,
    required this.status,
    required this.desc,
    required this.pds,
    required this.spds,
    required this.tdm,
    required this.fsg,
    required this.pricePerShare,
    required this.isDelete,
    required this.isDocument,
    required this.state,
    required this.propType,
    required this.firstInstallmentPrice,
    required this.propVoteCount,
    required this.basePrice,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    required this.fundTypeName,
    required this.fundType,
    required this.fundSubType,
    required this.minInvestment,
    required this.voteDescp,
    required this.isVote,
    required this.generalDocs,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json["id"],
        propertyName: json["property_name"] ?? '',
        propertyAddress: json["property_address"] ?? '',
        returns: json["returns"] ?? '',
        lvr: json["LVR"] ?? '',
        term: json["term"] ?? '',
        facility: '${json["facility"]}'.toDouble,
        status: json["status"] ?? '',
        desc: json["desc"] ?? '',
        pds: json["pds"],
        spds: json["spds"],
        tdm: json["tdm"],
        fsg: json["fsg"],
        pricePerShare: '${json["price_per_share"]}'.toDouble,
        isDelete: json["isDelete"] ?? '',
        isDocument: json["isDocument"] ?? '',
        state: json["state"] ?? '',
        firstInstallmentPrice: '${json["first_installment_price"]}'.toDouble,
        propVoteCount: json["prop_vote_count"],
        basePrice: '${json["base_price"]}'.toDouble,
        createdAt: json["createdAt"] ?? '',
        updatedAt: json["updatedAt"] ?? '',
        images: List<String>.from(json["images"].map((x) => x)),
        propType: getPropType(json["prop_category"]),
        fundTypeName: getFundTypeName(json["prop_type"]),
        fundType: json["prop_category"],
        fundSubType: json["prop_type"],
        minInvestment: json["minimum_investment"],
        voteDescp: json["vote_desc"],
        isVote: json["isvote"],
        generalDocs: json["general_files"] == null
            ? []
            : List<GeneralDocs>.from(
                json["general_files"].map((x) => GeneralDocs.fromJson(x))),
      );

  static String getPropType(int fundType) {
    switch (fundType) {
      case 1:
        return AppConstants.mortgageFund;
      case 2:
        return AppConstants.propertyFund;
      default:
        return '';
    }
  }

  static String getFundTypeName(int fundSubType) {
    switch (fundSubType) {
      case 0:
        return AppConstants.landBanking;
      case 1:
        return AppConstants.landDevelopment;
      case 2:
        return AppConstants.rental;
      case 3:
        return AppConstants.mortgageFund;
      case 4:
        return AppConstants.poolFund;
      default:
        return '';
    }
  }
}

class GeneralDocs {
  final String title;
  final String url;
  final String fileName;

  GeneralDocs({
    required this.title,
    required this.url,
    required this.fileName,
  });

  factory GeneralDocs.fromJson(Map<String, dynamic> json) {
    final url = json["generalfile"] ?? '';
    final uri = Uri.parse(url);
    final filename = uri.fileName;

    return GeneralDocs(
      title: '${json["file_type"]}'.capitalize,
      url: url,
      fileName: filename,
    );
  }
}
