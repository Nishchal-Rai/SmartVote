import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/election_model.dart';
import '../models/candidate_model.dart';

class ElectionProvider extends ChangeNotifier {
  List<ElectionModel> _elections = [];
  ElectionModel? _selectedElection;
  bool _isLoading = false;
  String? _error;

  List<ElectionModel> get elections => _elections;
  ElectionModel? get selectedElection => _selectedElection;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActiveElections() async {
    _setLoading(true);
    try {
      final res = await ApiService.getActiveElections();
      final list = res['data'] as List;
      _elections = list.map((e) => ElectionModel.fromJson(e)).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllElections() async {
    _setLoading(true);
    try {
      final res = await ApiService.getAllElections();
      final list = res['data'] as List;
      _elections = list.map((e) => ElectionModel.fromJson(e)).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadElection(int id) async {
    _setLoading(true);
    try {
      final res = await ApiService.getElection(id);
      _selectedElection = ElectionModel.fromJson(res['data']);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> castVote(int electionId, int candidateId) async {
    _setLoading(true);
    try {
      await ApiService.castVote(electionId, candidateId);
      // Refresh the election so hasVoted updates
      await loadElection(electionId);
      _error = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createElection(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await ApiService.createElection(data);
      await loadAllElections();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateStatus(int id, String status) async {
    _setLoading(true);
    try {
      await ApiService.updateElectionStatus(id, status);
      await loadAllElections();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
