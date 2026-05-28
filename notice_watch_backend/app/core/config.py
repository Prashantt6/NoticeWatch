from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    DATABASE_URL: str
    FIREBASE_CREDENTIALS: str

    # Allow extra env inputs (like SUPABASE_ANON_KEY, APKURL) so Settings
    # instantiation doesn't fail when unrelated environment variables exist.
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="allow",
    )


settings = Settings()
