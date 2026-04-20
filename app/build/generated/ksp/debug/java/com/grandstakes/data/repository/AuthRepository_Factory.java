package com.grandstakes.data.repository;

import com.grandstakes.data.db.UserDao;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata
@DaggerGenerated
@Generated(
    value = "dagger.internal.codegen.ComponentProcessor",
    comments = "https://dagger.dev"
)
@SuppressWarnings({
    "unchecked",
    "rawtypes",
    "KotlinInternal",
    "KotlinInternalInJava"
})
public final class AuthRepository_Factory implements Factory<AuthRepository> {
  private final Provider<UserDao> userDaoProvider;

  public AuthRepository_Factory(Provider<UserDao> userDaoProvider) {
    this.userDaoProvider = userDaoProvider;
  }

  @Override
  public AuthRepository get() {
    return newInstance(userDaoProvider.get());
  }

  public static AuthRepository_Factory create(Provider<UserDao> userDaoProvider) {
    return new AuthRepository_Factory(userDaoProvider);
  }

  public static AuthRepository newInstance(UserDao userDao) {
    return new AuthRepository(userDao);
  }
}
