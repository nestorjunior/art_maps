# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias ArtMaps.Repo
alias ArtMaps.Murals.{Artist, Mural}
alias ArtMaps.Accounts

# Limpar dados existentes
Repo.delete_all(Mural)
Repo.delete_all(Artist)

# Criar usuário admin (se não existir)
admin_email = "admin@artmaps.com"
unless Accounts.get_user_by_email(admin_email) do
  {:ok, admin} =
    Accounts.register_user(%{
      email: admin_email,
      password: "admin123456789"
    })

  admin
  |> Ecto.Changeset.change(%{approved: true, role: "admin", full_name: "Administrador"})
  |> Repo.update!()

  IO.puts("✅ Admin criado: #{admin_email} / senha: admin123456789")
end

# Criar artistas
kobra = Repo.insert!(%Artist{
  name: "Eduardo Kobra",
  bio: "Artista brasileiro conhecido por seus murais coloridos e vibrantes que retratam figuras históricas e culturais.",
  photo_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop",
  instagram: "@kobrastreetart",
  website: "https://www.eduardokobra.com",
  contact: "kobra@example.com"
})

ozi = Repo.insert!(%Artist{
  name: "Titi Freak",
  bio: "Artista urbano paulistano, conhecido por suas obras que misturam cultura pop e elementos brasileiros.",
  photo_url: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
  instagram: "@titifreak",
  contact: "titi@example.com"
})

speto = Repo.insert!(%Artist{
  name: "Speto",
  bio: "Grafiteiro paulistano com trabalhos reconhecidos pela técnica e estilo únicos.",
  photo_url: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
  instagram: "@speto",
  contact: "speto@example.com"
})

# Criar murais (usando coordenadas reais de São Paulo)
Repo.insert!(%Mural{
  title: "Mural das Etnias",
  description: "Gigantesco mural de 3.000 m² que representa os cinco continentes e celebra a diversidade cultural do mundo. Localizado na Avenida 23 de Maio, é um dos maiores murais do mundo.",
  latitude: -23.5629,
  longitude: -46.6544,
  image_url: "https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=800&h=600&fit=crop",
  artist: kobra
})

Repo.insert!(%Mural{
  title: "Einstein na Vila Madalena",
  description: "Retrato colorido de Albert Einstein, com cores vibrantes típicas do estilo de Kobra. Localizado no coração do distrito artístico da Vila Madalena.",
  latitude: -23.5505,
  longitude: -46.6900,
  image_url: "https://images.unsplash.com/photo-1549887552-1ecdc1e415f4?w=800&h=600&fit=crop",
  artist: kobra
})

Repo.insert!(%Mural{
  title: "Arte Urbana no Beco do Batman",
  description: "Mural vibrante localizado no famoso Beco do Batman, na Vila Madalena. O beco é um museu a céu aberto de arte de rua.",
  latitude: -23.5577,
  longitude: -46.6893,
  image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop",
  artist: ozi
})

Repo.insert!(%Mural{
  title: "Grafite na Avenida Paulista",
  description: "Obra contemporânea que mistura elementos da cultura brasileira com referências pop. Localizado próximo à estação de metrô.",
  latitude: -23.5613,
  longitude: -46.6563,
  image_url: "https://images.unsplash.com/photo-1499781350541-7783f6c6a0c8?w=800&h=600&fit=crop",
  artist: ozi
})

Repo.insert!(%Mural{
  title: "Mural no Largo da Batata",
  description: "Arte urbana que representa a história e transformação do Largo da Batata, importante ponto de encontro em Pinheiros.",
  latitude: -23.5617,
  longitude: -46.7010,
  image_url: "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800&h=600&fit=crop",
  artist: speto
})

Repo.insert!(%Mural{
  title: "Arte na 23 de Maio",
  description: "Mural que embeleza os pilares da Avenida 23 de Maio, transformando a paisagem urbana da cidade.",
  latitude: -23.5690,
  longitude: -46.6490,
  image_url: "https://images.unsplash.com/photo-1515405295579-ba7b45403062?w=800&h=600&fit=crop",
  artist: speto
})

IO.puts("✅ Seeds criados com sucesso!")
IO.puts("📊 #{Repo.aggregate(Artist, :count)} artistas cadastrados")
IO.puts("🎨 #{Repo.aggregate(Mural, :count)} murais cadastrados")
