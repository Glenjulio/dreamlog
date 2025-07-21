# db/seeds.rb - Seeds complets pour DreamLog

# Nettoyer la base existante en dev
if Rails.env.development?
  puts "Cleaning existing data..."
  Analysis.destroy_all
  Transcription.destroy_all
  Dream.destroy_all
  Personality.destroy_all
  User.destroy_all
  puts "Database cleaned"
end

# Fonction helper pour générer des analyses d'exemple
def generate_sample_analysis(dream, transcription)
  case transcription.tag
  when "lucid_dream"
    "Cette expérience de vol lucide suggère un fort désir de liberté et de contrôle dans votre vie. Le fait de pouvoir contrôler votre vol par la pensée indique une confiance croissante en vos capacités personnelles. La vue panoramique de la ville représente peut-être une nouvelle perspective sur votre environnement quotidien. Les couleurs chaudes du coucher de soleil symbolisent souvent l'espoir et la transformation positive."

  when "nightmare"
    "Ce rêve de labyrinthe reflète possiblement des sentiments de confusion ou d'être 'perdu' dans une situation de votre vie éveillée. Les murs qui s'élèvent peuvent représenter des obstacles qui semblent grandir. Cependant, la découverte finale que la sortie était proche suggère que les solutions à vos défis actuels sont peut-être plus accessibles que vous ne le pensez."

  when "work_related"
    "Ce rêve fascinant mélange votre expertise professionnelle avec une vision cosmique. Debugger l'univers suggère un désir de comprendre et d'améliorer les systèmes complexes qui vous entourent. Cela peut refléter votre approche analytique face aux défis de la vie, ainsi qu'un sentiment de responsabilité ou de pouvoir dans votre domaine d'expertise."

  when "symbolic"
    "La maison des souvenirs est un symbole puissant de votre psyché et de votre développement personnel. Chaque pièce représente une phase de votre vie, et votre capacité à les explorer suggère une bonne connexion avec votre histoire personnelle. Ce rêve indique un processus sain d'intégration de vos expériences passées."

  else
    "Ce rêve présente des éléments symboliques riches qui méritent une exploration approfondie. Les émotions ressenties pendant le rêve sont particulièrement significatives et peuvent offrir des insights sur votre état psychologique actuel. Je recommande de tenir un journal de rêves pour identifier les patterns récurrents."
  end
end

# Créer des utilisateurs de test
puts "Creating users..."

users = [
  {
    email: "alice@dreamlog.com",
    password: "password123",
    first_name: "Alice",
    last_name: "Wonder",
    personality: {
      age: 28,
      job: "Graphic Designer",
      gender: "Female",
      description: "Creative and introspective person who loves art and symbolism.",
      relationship: "In a relationship",
      mood: "optimistic"
    }
  },
  {
    email: "bob@dreamlog.com",
    password: "password123",
    first_name: "Bob",
    last_name: "Dreamer",
    personality: {
      age: 35,
      job: "Software Engineer",
      gender: "Male",
      description: "Analytical mind who enjoys problem-solving and technology.",
      relationship: "Single",
      mood: "curious"
    }
  },
  {
    email: "charlie@dreamlog.com",
    password: "password123",
    first_name: "Charlie",
    last_name: "Night",
    personality: {
      age: 42,
      job: "Psychologist",
      gender: "Non-binary",
      description: "Professional dream analyst with deep understanding of the subconscious.",
      relationship: "Married",
      mood: "contemplative"
    }
  }
]

created_users = users.map do |user_data|
  personality_data = user_data.delete(:personality)

  user = User.create!(user_data)
  user.create_personality!(personality_data)

  puts "  Created user: #{user.first_name} #{user.last_name}"
  user
end

# Exemples de rêves réalistes avec transcriptions
puts "Creating dreams with transcriptions..."

dreams_data = [
  # Alice's dreams
  {
    user: created_users[0],
    title: "Flying Over the City",
    tags: "flying, freedom, city",
    private: false,
    transcription: {
      content: "I was flying high above my hometown, looking down at all the buildings and streets. The feeling was incredible - pure freedom and lightness. I could control my flight by just thinking about where I wanted to go. The city looked like a miniature model, and I felt so peaceful and powerful at the same time. I remember flying towards the sunset, and the whole sky was painted in beautiful orange and pink colors.",
      mood: "positive",
      tag: "lucid_dream",
      rating: 9
    }
  },
  {
    user: created_users[0],
    title: "Lost in a Maze",
    tags: "maze, confusion, anxiety",
    private: false,
    transcription: {
      content: "I found myself in an enormous hedge maze. Every turn I took led to another dead end. The walls kept getting higher and higher, and I started to panic. I could hear voices calling my name, but I couldn't tell where they were coming from. The more I ran, the more lost I became. Finally, I climbed one of the hedge walls and saw the exit was actually very close to where I started.",
      mood: "anxious",
      tag: "nightmare",
      rating: 4
    }
  },

  # Bob's dreams
  {
    user: created_users[1],
    title: "Debugging the Universe",
    tags: "programming, universe, surreal",
    private: false,
    transcription: {
      content: "I was sitting at my computer, but instead of code, I was debugging the laws of physics. Gravity had a syntax error, and people were floating around randomly. I had to fix the quantum mechanics module because particles were behaving like JavaScript arrays. The strangest part was that my IDE was showing the source code of reality, and I could actually compile and run changes to the universe.",
      mood: "curious",
      tag: "work_related",
      rating: 8
    }
  },
  {
    user: created_users[1],
    title: "Back to School Exam",
    tags: "school, exam, stress",
    private: true,
    transcription: {
      content: "I was back in high school, sitting in a math exam I completely forgot about. Everyone around me was writing furiously, but I couldn't remember any formulas. The clock was ticking loudly, and the teacher kept staring at me. I tried to write something, anything, but my pen wouldn't work. When I looked at the paper again, all the questions were in a language I didn't understand.",
      mood: "anxious",
      tag: "recurring",
      rating: 3
    }
  },

  # Charlie's dreams
  {
    user: created_users[2],
    title: "Therapy Session with Animals",
    tags: "therapy, animals, communication",
    private: false,
    transcription: {
      content: "I was conducting a therapy session, but all my clients were animals. A wise old elephant was telling me about his childhood trauma, while a nervous rabbit was having anxiety about social situations. The most surprising thing was that I could understand them perfectly, and they seemed to really benefit from our conversations. A proud lion was working through anger management issues, and by the end of the session, all the animals seemed more at peace.",
      mood: "positive",
      tag: "professional",
      rating: 7
    }
  },
  {
    user: created_users[2],
    title: "House of Memories",
    tags: "house, memories, nostalgia",
    private: true,
    transcription: {
      content: "I was exploring a house where each room contained memories from different periods of my life. The childhood room was bright and colorful, filled with toys and laughter. The teenage room was messy and dark, with loud music playing. The college room smelled like coffee and had books scattered everywhere. As I walked through each room, I could actually relive those moments and feel the emotions I had back then.",
      mood: "contemplative",
      tag: "symbolic",
      rating: 9
    }
  }
]

# Créer les rêves avec transcriptions
dreams_data.each do |dream_data|
  transcription_data = dream_data.delete(:transcription)

  dream = Dream.create!(dream_data)
  transcription = dream.create_transcription!(transcription_data)

  puts "  Created dream: '#{dream.title}' for #{dream.user.first_name}"

  # Créer quelques analyses pour certains rêves
  if [true, false, true].sample # Aléatoire
    analysis_content = generate_sample_analysis(dream, transcription)
    transcription.create_analysis!(content: analysis_content)
    puts "    Added AI analysis"
  end
end

# Quelques rêves publics supplémentaires pour la diversité
puts "Creating additional public dreams..."

additional_dreams = [
  {
    user: created_users.sample,
    title: "Time Travel Café",
    tags: "time_travel, café, past",
    private: false,
    transcription: {
      content: "I walked into a small café, but each table was from a different time period. At one table, people in 1920s clothing were drinking coffee and discussing jazz music. Another table had medieval knights planning a quest. I sat at a futuristic table where robots were serving holographic food. The barista told me I could order any drink from any era, so I asked for a coffee that would taste like my grandmother's kitchen.",
      mood: "curious",
      tag: "surreal",
      rating: 8
    }
  },
  {
    user: created_users.sample,
    title: "Ocean of Stars",
    tags: "ocean, stars, cosmic",
    private: false,
    transcription: {
      content: "Instead of water, the ocean was filled with liquid starlight. I was swimming through constellations, and each stroke created ripples of cosmic dust. Fish made of pure light swam alongside me, and when I looked up, I could see planets floating like islands above the surface. The most beautiful part was that I could breathe the starlight like air, and it filled me with an incredible sense of connection to the universe.",
      mood: "transcendent",
      tag: "spiritual",
      rating: 10
    }
  }
]

additional_dreams.each do |dream_data|
  transcription_data = dream_data.delete(:transcription)

  dream = Dream.create!(dream_data)
  dream.create_transcription!(transcription_data)

  puts "  Created additional dream: '#{dream.title}'"
end

# Statistiques finales
puts "\nSeeds completed successfully!"
puts "Users created: #{User.count}"
puts "Personalities created: #{Personality.count}"
puts "Dreams created: #{Dream.count}"
puts "Transcriptions created: #{Transcription.count}"
puts "Analyses created: #{Analysis.count}"
puts "Public dreams: #{Dream.where(private: [false, nil]).count}"
puts "Private dreams: #{Dream.where(private: true).count}"

puts "\nTest accounts:"
users.each do |user_data|
  puts "  #{user_data[:email]} / #{user_data[:password]}"
end

puts "\nReady to explore DreamLog!"
