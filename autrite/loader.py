import pickle
class Loader:
    @staticmethod
    def load_constraints(filename):
        pass

    @staticmethod
    def load_queries(filename):
        with open(filename, 'rb') as f:
            queries = pickle.load(f)
        return queries
