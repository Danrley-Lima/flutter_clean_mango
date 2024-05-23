import 'package:ForDev/data/http/http.dart';
import 'package:ForDev/data/usecases/usecases.dart';
import 'package:ForDev/domain/helpers/helpers.dart';
import 'package:ForDev/domain/usecases/usecases.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClient;
  String url;
  AuthenticationParams params;

  Map mockvalidData() =>
      {"accessToken": faker.guid.guid(), "name": faker.person.name()};

  PostExpectation mockRequest() => when(
        httpClient.request(
          url: anyNamed('url'),
          method: anyNamed('method'),
          body: anyNamed('body'),
        ),
      );

  void mockHttpData(Map data) {
    mockRequest().thenAnswer(
      (_) async => data,
    );
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
    mockHttpData(mockvalidData());
  });

  test("Should call HttpClient with correct values", () async {
    await sut.auth(params: params);

    verify(
      httpClient.request(
        url: url,
        method: 'post',
        body: {"email": params.email, "password": params.password},
      ),
    );
  });

  test("Should throw UnexpectedError if HttpClient returns 400", () async {
    mockHttpError(HttpError.badRequest);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test("Should throw UnexpectedError if HttpClient returns 404", () async {
    mockHttpError(HttpError.notFound);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test("Should throw UnexpectedError if HttpClient returns 500", () async {
    mockHttpError(HttpError.serverError);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test("Should throw InvalidCredentialsError if HttpClient returns 401",
      () async {
    mockHttpError(HttpError.unauthorized);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test("Should return an Account if HttpClient returns 200", () async {
    final validData = mockvalidData();
    mockHttpData(validData);

    final account = await sut.auth(params: params);

    expect(account.token, validData["accessToken"]);
  });

  test(
      "Should throw UnexpectedError if HttpClient returns 200 with invalid data",
      () async {
    mockHttpData({"invalid_key": "invalid_value"});

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });
}
