import 'package:flutter_test/flutter_test.dart';
import 'package:exematching/models/mentor.dart';
import 'package:exematching/models/student.dart';
import 'package:exematching/services/local/local_database.dart';
import 'package:exematching/services/local/local_mentor_repository.dart';

void main() {
  group('Mentor model', () {
    test('initials computation and quota calculation', () {
      const mentor = Mentor(
        id: 'm1',
        fullName: 'Dr. Nguyen Thanh',
        email: 'thanhnt@fpt.edu.vn',
        title: 'Senior Lecturer',
        department: 'Software Engineering',
        expertise: ['AI/ML', 'Robotics'],
        bio: 'Researching computer vision.',
        maxQuota: 5,
        currentAssigned: 2,
      );

      expect(mentor.initials, 'NT');
      expect(mentor.isAvailable, isTrue);
      expect(mentor.remainingSlots, 3);
    });

    test('isAvailable is false when quota is reached', () {
      const mentor = Mentor(
        id: 'm2',
        fullName: 'Prof. Le Long',
        email: 'long@fpt.edu.vn',
        title: 'Professor',
        department: 'Information Systems',
        expertise: ['Blockchain'],
        bio: 'Blockchain specialist.',
        maxQuota: 3,
        currentAssigned: 3,
      );

      expect(mentor.isAvailable, isFalse);
      expect(mentor.remainingSlots, 0);
    });

    test('fromJson and toJson round-trip preserves fields', () {
      final json = {
        'id': 'm3',
        'fullName': 'Dr. Tran Minh Chau',
        'email': 'chautm@fpt.edu.vn',
        'title': 'Associate Professor',
        'department': 'Computer Science',
        'expertise': ['AI/ML', 'Data Science'],
        'bio': 'Data science researcher.',
        'office': 'Room 402, Alpha Building',
        'maxQuota': 4,
        'currentAssigned': 1,
        'mentoredTeamNames': ['EduSmart Analytics'],
      };

      final mentor = Mentor.fromJson(json);
      expect(mentor.id, 'm3');
      expect(mentor.fullName, 'Dr. Tran Minh Chau');
      expect(mentor.expertise, contains('AI/ML'));
      expect(mentor.mentoredTeamNames, contains('EduSmart Analytics'));

      final out = mentor.toJson();
      expect(out['id'], 'm3');
      expect(out['maxQuota'], 4);
    });
  });

  group('MentorRequest model', () {
    test('round-trip serialization', () {
      const student = Student(
        id: 's1',
        email: 'student@fpt.edu.vn',
        fullName: 'Minh Le',
        studentCode: 'SE160234',
        major: 'Software Engineering',
        cohort: '2026',
      );

      final req = MentorRequest.create(
        id: 'req_123',
        teamId: 'team_ai04',
        teamName: 'Team AI-04',
        mentorId: 'm1',
        mentorName: 'Dr. Nguyen Thanh',
        sender: student,
        message: 'We would love to have you as our mentor.',
      );

      expect(req.status, MentorRequestStatus.pending);
      expect(req.senderName, 'Minh Le');

      final json = req.toJson();
      final revived = MentorRequest.fromJson(json);
      expect(revived.id, 'req_123');
      expect(revived.teamName, 'Team AI-04');
      expect(revived.status, MentorRequestStatus.pending);
    });
  });

  group('LocalMentorRepository', () {
    late LocalDatabase db;
    late LocalMentorRepository repo;

    setUp(() {
      db = LocalDatabase(latency: Duration.zero, requireNetwork: false);
      db.mentors['m1'] = const Mentor(
        id: 'm1',
        fullName: 'Dr. Nguyen Thanh',
        email: 'thanhnt@fpt.edu.vn',
        title: 'Senior Lecturer',
        department: 'Software Engineering',
        expertise: ['AI/ML', 'Computer Vision'],
        bio: 'AI researcher',
        maxQuota: 5,
        currentAssigned: 1,
      );
      db.mentors['m2'] = const Mentor(
        id: 'm2',
        fullName: 'MSc. Le Hoang Long',
        email: 'longlh@fpt.edu.vn',
        title: 'Lecturer',
        department: 'Information Systems',
        expertise: ['Web/Cloud', 'Blockchain'],
        bio: 'FinTech researcher',
        maxQuota: 2,
        currentAssigned: 2, // Full
      );
      repo = LocalMentorRepository(db);
    });

    test('searchMentors filters by query and availability', () async {
      final all = await repo.searchMentors();
      expect(all.length, 2);

      final aiMatches = await repo.searchMentors(query: 'Vision');
      expect(aiMatches.length, 1);
      expect(aiMatches.first.id, 'm1');

      final availableOnly = await repo.searchMentors(availableOnly: true);
      expect(availableOnly.length, 1);
      expect(availableOnly.first.id, 'm1');
    });

    test('requestMentor submits request successfully', () async {
      const student = Student(
        id: 's1',
        email: 'student@fpt.edu.vn',
        fullName: 'Minh Le',
        studentCode: 'SE160234',
        major: 'Software Engineering',
        cohort: '2026',
      );

      final req = await repo.requestMentor(
        teamId: 'team_ai04',
        teamName: 'Team AI-04',
        mentorId: 'm1',
        mentorName: 'Dr. Nguyen Thanh',
        sender: student,
        message: 'Please mentor our team',
      );

      expect(req.teamId, 'team_ai04');
      final requests = await repo.getRequestsForTeam('team_ai04');
      expect(requests.length, 1);
      expect(requests.first.mentorId, 'm1');
    });

    test('requestMentor throws when mentor quota is reached', () async {
      const student = Student(
        id: 's1',
        email: 'student@fpt.edu.vn',
        fullName: 'Minh Le',
        studentCode: 'SE160234',
        major: 'Software Engineering',
        cohort: '2026',
      );

      expect(
        () => repo.requestMentor(
          teamId: 'team_ai04',
          teamName: 'Team AI-04',
          mentorId: 'm2',
          mentorName: 'MSc. Le Hoang Long',
          sender: student,
          message: 'Hello',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('cancelRequest removes request', () async {
      const student = Student(
        id: 's1',
        email: 'student@fpt.edu.vn',
        fullName: 'Minh Le',
        studentCode: 'SE160234',
        major: 'Software Engineering',
        cohort: '2026',
      );

      final req = await repo.requestMentor(
        teamId: 'team_ai04',
        teamName: 'Team AI-04',
        mentorId: 'm1',
        mentorName: 'Dr. Nguyen Thanh',
        sender: student,
        message: 'Test message',
      );

      var requests = await repo.getRequestsForTeam('team_ai04');
      expect(requests.length, 1);

      await repo.cancelRequest(req.id);
      requests = await repo.getRequestsForTeam('team_ai04');
      expect(requests, isEmpty);
    });
  });
}
