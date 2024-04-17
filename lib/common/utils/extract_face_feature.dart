import 'package:attendance_with_laravel/model/user_model.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

Future<List<FeaturePoint>> extractFaceFeatures(
    InputImage inputImage, FaceDetector faceDetector) async {
  List<Face> faceList = await faceDetector.processImage(inputImage);
  if (faceList.isEmpty) {
    throw Exception('No faces detected');
  }
  Face face = faceList.first;

  List<FeaturePoint> faceFeatures = [
    FeaturePoint(
      featureName: 'rightEar',
    points: Points(
      x: (face.landmarks[FaceLandmarkType.rightEar])?.position.x.toInt(),
      y: (face.landmarks[FaceLandmarkType.rightEar])?.position.y.toInt())
    ), FeaturePoint(
        featureName: 'leftEar',
        points: Points(
            x: (face.landmarks[FaceLandmarkType.leftEar])?.position.x.toInt(),
            y: (face.landmarks[FaceLandmarkType.leftEar])?.position.y.toInt())
    ),
    FeaturePoint(
        featureName: 'rightMouth',
        points: Points(
            x: (face.landmarks[FaceLandmarkType.rightMouth])?.position.x.toInt(),
            y: (face.landmarks[FaceLandmarkType.rightMouth])?.position.y.toInt())
    ),
    FeaturePoint(
        featureName: 'leftMouth',
        points: Points(
            x: (face.landmarks[FaceLandmarkType.leftMouth])?.position.x.toInt(),
            y: (face.landmarks[FaceLandmarkType.leftMouth])?.position.y.toInt())
    ),
    FeaturePoint(
        featureName: 'rightEye',
        points: Points(
            x: (face.landmarks[FaceLandmarkType.rightEye])?.position.x.toInt(),
            y: (face.landmarks[FaceLandmarkType.rightEye])?.position.y.toInt())
    ),
    FeaturePoint(
        featureName: 'leftEye',
        points: Points(
            x: (face.landmarks[FaceLandmarkType.leftEye])?.position.x.toInt(),
            y: (face.landmarks[FaceLandmarkType.leftEye])?.position.y.toInt())
    ),
    FeaturePoint(
        featureName: 'rightCheek',
        points: Points(
            x: (face.landmarks[FaceLandmarkType.rightCheek])?.position.x.toInt(),
            y: (face.landmarks[FaceLandmarkType.rightCheek])?.position.y.toInt())
    ),
    FeaturePoint(
        featureName: 'leftCheek',
        points: Points(
            x: (face.landmarks[FaceLandmarkType.leftCheek])?.position.x.toInt(),
            y: (face.landmarks[FaceLandmarkType.leftCheek])?.position.y.toInt())
    ),
    FeaturePoint(
        featureName: 'noseBase',
        points: Points(
            x: (face.landmarks[FaceLandmarkType.noseBase])?.position.x.toInt(),
            y: (face.landmarks[FaceLandmarkType.noseBase])?.position.y.toInt())
    ),
    FeaturePoint(
        featureName: 'bottomMouth',
        points: Points(
            x: (face.landmarks[FaceLandmarkType.bottomMouth])?.position.x.toInt(),
            y: (face.landmarks[FaceLandmarkType.bottomMouth])?.position.y.toInt())
    ),
    ];








  return faceFeatures;
}
