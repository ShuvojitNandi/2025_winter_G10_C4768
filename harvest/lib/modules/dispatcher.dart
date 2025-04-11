typedef Callback<T> = void Function(T content);

class Connection<B> {
  Dispatcher dispatcher;
  Callback<B> callback;

  Connection(this.dispatcher, this.callback);

  disconnect() {}
}

class Dispatcher<A> {
  Map<int, Connection<A>> bindings = {};

  Connection connect(Callback<A> callback) {
    Connection<A> connection = Connection<A>(this, callback);
    bindings[connection.hashCode] = connection;

    return connection;
  }

  disconnect(Connection connection) {
    bindings.remove(connection.hashCode);
  }

  fire(A argument) {
    for (Connection<A> connection in bindings.values) {
      connection.callback(argument);
    }
  }
}
