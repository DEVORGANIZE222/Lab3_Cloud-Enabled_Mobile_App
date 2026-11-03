import 'package:flutter_test/flutter_test.dart';
import 'package:exematching/models/student.dart';
import 'package:exematching/models/team.dart';
import 'package:exematching/services/local/local_database.dart';
import 'package:exematching/services/local/local_team_repository.dart';

void main() {
  group('Leader voting and resignation', () {
    late LocalDatabase db;
    late LocalTeamRepository repo;

    const s1 = Student(
      id: 's1',
      fullName: 'Minh Le',
      email: 'minh.le@fpt.edu.vn',
      major: 'Software Engineering',
      studentCode: 'SE160234',
      cohort: '2026',
    );
    const s2 = Student(
      id: 's2',
      fullName: 'Hoang Tran',
      email: 'hoang.tran@fpt.edu.vn',
      major: 'Software Engineering',
      studentCode: 'SE170456',
      cohort: '2026',
    );
    const s3 = Student(
      id: 's3',
      fullName: 'Quynh Nguyen',
      email: 'quynh.nguyen@fpt.edu.vn',
      major: 'Software Engineering',
      studentCode: 'SE170189',
      cohort: '2026',
    );

    setUp(() {
      db = LocalDatabase(latency: Duration.zero, requireNetwork: false);
      repo = LocalTeamRepository(db);

      // Create a team with 3 members
      final team = Team(
        id: 'test_team',
        code: 'TEST01',
        name: 'Test Team',
        topic: 'AI Matching',
        description: 'Test description',
        category: 'AI',
        tags: ['Flutter', 'AI'],
        supervisor: 'Dr. Nguyen Thanh',
        members: [
          TeamMember.fromStudent(s1, 'Frontend'),
          TeamMember.fromStudent(s2, 'Backend'),
          TeamMember.fromStudent(s3, 'AI'),
        ],
        openRoles: ['DevOps', 'Mobile'],
        capacity: 5,
      );
      db.putTeam(team);
    });

    test('casting majority votes elects leader', () async {
      // 3 members -> votesNeeded = 2
      var team = await repo.castVote('test_team', 's1', 's1');
      expect(team.hasLeader, isFalse);

      team = await repo.castVote('test_team', 's2', 's1');
      expect(team.hasLeader, isTrue);
      expect(team.leaderId, 's1');
    });

    test('resignLeader clears leader and removes votes for that candidate', () async {
      // Elect s1 as leader
      await repo.castVote('test_team', 's1', 's1');
      var team = await repo.castVote('test_team', 's2', 's1');
      expect(team.leaderId, 's1');

      // s1 resigns
      team = await repo.resignLeader('test_team', 's1');
      expect(team.hasLeader, isFalse);
      expect(team.leaderId, isNull);
      expect(team.votesFor('s1'), 0);

      // Other member s2 can now be elected leader
      await repo.castVote('test_team', 's1', 's2');
      team = await repo.castVote('test_team', 's3', 's2');
      expect(team.hasLeader, isTrue);
      expect(team.leaderId, 's2');
    });

    test('non-leader cannot resign', () async {
      await repo.castVote('test_team', 's1', 's1');
      await repo.castVote('test_team', 's2', 's1');

      expect(
        () => repo.resignLeader('test_team', 's2'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
