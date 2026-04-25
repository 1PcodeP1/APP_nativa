package com.grandstakes.ui.main;

import com.grandstakes.data.repository.AuthRepository;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata
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
public final class LobbyViewModel_Factory implements Factory<LobbyViewModel> {
  private final Provider<AuthRepository> repositoryProvider;

  public LobbyViewModel_Factory(Provider<AuthRepository> repositoryProvider) {
    this.repositoryProvider = repositoryProvider;
  }

  @Override
  public LobbyViewModel get() {
    return newInstance(repositoryProvider.get());
  }

  public static LobbyViewModel_Factory create(Provider<AuthRepository> repositoryProvider) {
    return new LobbyViewModel_Factory(repositoryProvider);
  }

  public static LobbyViewModel newInstance(AuthRepository repository) {
    return new LobbyViewModel(repository);
  }
}
