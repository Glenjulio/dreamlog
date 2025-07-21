# db/seeds.rb - Seeds optimisés et corrigés pour DreamLog

# Nettoyage sécurisé (développement uniquement)
if Rails.env.development?
  puts "Nettoyage des données de développement..."
  Analysis.destroy_all
  Transcription.destroy_all
  Dream.destroy_all
  Personality.destroy_all
  User.destroy_all
  puts "Base de données nettoyée"
end

# Fonction d'analyse robuste avec gestion d'erreurs
def generate_realistic_analysis(transcription)
  return "Analyse en cours de génération..." if transcription.nil?

  begin
    case transcription.tag
    when "reve_lucide"
      "Cette expérience de vol lucide révèle un désir profond de liberté et de maîtrise de votre destinée. La capacité à contrôler votre vol symbolise une confiance grandissante en vos propres capacités. La vue panoramique suggère une prise de recul bénéfique sur votre situation actuelle. Les couleurs chaudes du coucher de soleil sont généralement associées à l'espoir et aux transitions positives dans votre vie."

    when "cauchemar"
      "Ce rêve angoissant peut refléter des tensions ou des préoccupations non résolues dans votre vie éveillée. Les éléments chaotiques symbolisent souvent un sentiment de perte de contrôle face à certaines situations. Cependant, le fait de vous réveiller marque votre capacité à échapper aux difficultés. Ces rêves nous rappellent l'importance de traiter nos stress quotidiens."

    when "professionnel"
      "Votre rêve mélange ingénieusement votre expertise professionnelle avec une dimension créative ou fantastique. Cette fusion révèle votre engagement profond dans votre domaine d'activité et votre désir d'excellence. Les éléments surréalistes peuvent représenter votre capacité d'innovation et votre approche unique des défis professionnels."

    when "symbolique"
      "Ce rêve riche en symboles mérite une attention particulière. Les images et métaphores qui apparaissent sont souvent des messages de votre inconscient concernant votre développement personnel. L'exploration de ces espaces oniriques reflète votre quête de compréhension de vous-même et de votre place dans le monde."

    when "anxiete"
      "Ce type de rêve anxiogène est très courant et reflète généralement des inquiétudes liées à la performance ou à l'évaluation. L'incapacité à agir efficacement dans le rêve symbolise souvent une peur de ne pas être à la hauteur des attentes. Ces rêves sont plus liés au stress qu'à vos compétences réelles et diminuent généralement avec la gestion de l'anxiété."

    when "spirituel"
      "Votre rêve évoque une quête spirituelle et un désir de connexion avec quelque chose de plus grand que soi. Les éléments cosmiques ou transcendants suggèrent une phase de croissance personnelle importante. Ce type de rêve survient souvent lors de périodes de réflexion profonde sur le sens de la vie et votre rôle dans l'univers."

    when "nature"
      "Les éléments naturels dans vos rêves représentent souvent votre connexion avec vos instincts profonds et votre besoin de retour aux sources. La nature symbolise la croissance, le renouveau et les cycles de la vie. Ce rêve peut indiquer un besoin de vous reconnecter avec des valeurs essentielles ou de prendre du recul par rapport au stress urbain."

    else
      "Votre rêve présente des éléments symboliques riches qui méritent une exploration approfondie. Les émotions ressenties pendant le rêve sont particulièrement révélatrices de votre état psychologique actuel. Je recommande de noter les détails récurrents dans vos rêves pour identifier des patterns personnels significatifs qui pourraient éclairer votre développement personnel."
    end
  rescue StandardError => e
    Rails.logger.error "Erreur dans generate_realistic_analysis: #{e.message}"
    "Analyse temporairement indisponible. Les émotions et symboles de ce rêve restent néanmoins précieux pour votre compréhension personnelle."
  end
end

# Création des utilisateurs avec profils complets
puts "Création des utilisateurs..."

users_data = [
  {
    email: "alice.dubois@dreamlog.com",
    password: "password123",
    first_name: "Alice",
    last_name: "Dubois",
    personality: {
      age: 28,
      job: "Designer graphique",
      gender: "Femme",
      description: "Créative passionnée par l'art digital et le design d'expérience utilisateur. Sensible aux couleurs, aux formes et à l'esthétique. Cherche constamment l'inspiration dans son quotidien.",
      relationship: "En couple",
      mood: "inspirée"
    }
  },
  {
    email: "Adrien.martin@dreamlog.com",
    password: "password123",
    first_name: "Adrien",
    last_name: "Martin",
    personality: {
      age: 34,
      job: "Développeur Full-Stack",
      gender: "Homme",
      description: "Passionné de technologie et de résolution de problèmes complexes. Esprit analytique et méthodique qui aime comprendre le fonctionnement des systèmes. Fan de science-fiction.",
      relationship: "Célibataire",
      mood: "curieux"
    }
  },
  {
    email: "marie.leroy@dreamlog.com",
    password: "password123",
    first_name: "Marie",
    last_name: "Leroy",
    personality: {
      age: 41,
      job: "Psychologue clinicienne",
      gender: "Femme",
      description: "Spécialiste en thérapie cognitive et comportementale avec un intérêt particulier pour l'analyse des rêves. Approche empathique et professionnelle dans l'accompagnement de ses patients.",
      relationship: "Mariée",
      mood: "bienveillante"
    }
  },
  {
    email: "sophie.bernard@dreamlog.com",
    password: "password123",
    first_name: "Sophie",
    last_name: "Bernard",
    personality: {
      age: 29,
      job: "Photographe freelance",
      gender: "Femme",
      description: "Artiste indépendante spécialisée dans la photographie de portrait et de nature. Voyage beaucoup pour ses projets et s'inspire des rencontres humaines et des paysages.",
      relationship: "En couple",
      mood: "aventureuse"
    }
  },
  {
    email: "lucas.moreau@dreamlog.com",
    password: "password123",
    first_name: "Lucas",
    last_name: "Moreau",
    personality: {
      age: 38,
      job: "Chef d'entreprise",
      gender: "Homme",
      description: "Entrepreneur dans le secteur du bien-être et de la santé mentale. Ancien cadre stressé reconverti pour créer un équilibre entre performance et sérénité personnelle.",
      relationship: "Divorcé",
      mood: "réfléchi"
    }
  }
]

# Création optimisée des utilisateurs
created_users = users_data.map do |user_data|
  personality_data = user_data.delete(:personality)

  user = User.create!(user_data)
  user.create_personality!(personality_data)

  puts "  Utilisateur créé : #{user.first_name} #{user.last_name} (#{user.personality.job})"
  user
end

# Rêves détaillés et réalistes
puts "Création des rêves avec transcriptions..."

dreams_data = [
  # Rêves d'Alice (Designer)
  {
    user: created_users[0],
    title: "L'atelier de création infinie",
    tags: "créativité, art, inspiration",
    private: false,
    transcription: {
      content: "Je me trouvais dans un atelier immense aux murs couverts de toiles vierges. Chaque fois que je touchais une toile, elle se remplissait automatiquement de couleurs magnifiques qui correspondaient exactement à ce que je ressentais. Les pinceaux volaient dans l'air et peignaient des formes que je n'avais jamais imaginées. C'était comme si toute ma créativité refoulée s'exprimait enfin librement. La lumière dorée qui filtrait par les grandes fenêtres donnait vie à chaque création.",
      mood: "inspirée",
      tag: "reve_lucide",
      rating: 9
    }
  },
  {
    user: created_users[0],
    title: "Présentation client cauchemardesque",
    tags: "travail, stress, présentation",
    private: true,
    transcription: {
      content: "J'étais face à un client très important, mais ma présentation PowerPoint affichait n'importe quoi. Les slides montraient des images de chats à la place de mes maquettes. Plus j'essayais de corriger, pire cela devenait. Le client me regardait avec un air déçu et je sentais ma crédibilité s'effondrer. Mes collègues chuchotaient dans mon dos. Je me suis réveillée en sueur, soulagée que ce ne soit qu'un rêve.",
      mood: "stressée",
      tag: "cauchemar",
      rating: 3
    }
  },

  # Rêves de Thomas (Développeur)
  {
    user: created_users[1],
    title: "Le code qui réécrit la réalité",
    tags: "programmation, réalité, pouvoir",
    private: false,
    transcription: {
      content: "J'étais devant mon ordinateur, mais au lieu de coder une application web, je programmais la réalité elle-même. Chaque ligne de code que j'écrivais modifiait instantanément le monde autour de moi. J'ai corrigé un bug dans les lois de la gravité et soudain, tout le monde pouvait voler. J'ai optimisé l'algorithme du temps et les journées ont duré plus longtemps. C'était grisant de se sentir si puissant, mais aussi effrayant d'avoir autant de responsabilités.",
      mood: "fasciné",
      tag: "professionnel",
      rating: 8
    }
  },
  {
    user: created_users[1],
    title: "L'escape game mental",
    tags: "logique, énigme, pression",
    private: true,
    transcription: {
      content: "Je participais à un escape game géant dans une bibliothèque ancienne. Chaque énigme résolue déverrouillait une nouvelle section, mais le temps était compté. Les murs bougeaient, les livres se refermaient brusquement, et je sentais la pression monter. D'autres participants me regardaient résoudre les puzzles mathématiques. Une alarme retentissait à chaque erreur. Malgré le stress, j'étais totalement absorbé par le défi.",
      mood: "concentré",
      tag: "anxiete",
      rating: 6
    }
  },

  # Rêves de Marie (Psychologue)
  {
    user: created_users[2],
    title: "Thérapie dans un jardin enchanté",
    tags: "thérapie, nature, guérison",
    private: false,
    transcription: {
      content: "Je menais une séance de thérapie dans un magnifique jardin où chaque plante représentait une émotion différente. Mes patients étaient plus détendus que jamais, et les mots semblaient avoir un pouvoir de guérison immédiat. Les fleurs s'épanouissaient quand nous abordions des sujets positifs, et les épines disparaissaient quand nous résolvions des traumatismes. C'était ma vision idéale de la thérapie : un espace où la guérison devient tangible et visible.",
      mood: "apaisée",
      tag: "professionnel",
      rating: 9
    }
  },
  {
    user: created_users[2],
    title: "La maison des souvenirs d'enfance",
    tags: "enfance, mémoire, nostalgie",
    private: true,
    transcription: {
      content: "Je me promenais dans la maison de mon enfance, mais chaque pièce contenait des souvenirs que j'avais oubliés. Dans la cuisine, je me revoyais faire des gâteaux avec ma grand-mère. Dans ma chambre d'enfant, tous mes jouets étaient encore là, comme si le temps s'était arrêté. Ces souvenirs étaient si vivaces que j'avais l'impression de revivre ces moments. C'était à la fois nostalgique et réconfortant de retrouver ces parcelles de bonheur oubliées.",
      mood: "nostalgique",
      tag: "symbolique",
      rating: 8
    }
  },

  # Rêves de Sophie (Photographe)
  {
    user: created_users[3],
    title: "Safari photo dans un monde parallèle",
    tags: "photographie, voyage, découverte",
    private: false,
    transcription: {
      content: "Je participais à un safari photo dans un monde où les animaux étaient translucides et lumineux. Chaque cliché que je prenais révélait des détails invisibles à l'œil nu : les émotions des animaux apparaissaient en couleurs autour d'eux. Mon appareil photo avait le pouvoir de capturer l'âme des créatures. Plus je photographiais, plus je comprenais le langage secret de la nature. C'était l'expérience photographique la plus intense de ma vie.",
      mood: "émerveillée",
      tag: "professionnel",
      rating: 9
    }
  },
  {
    user: created_users[3],
    title: "Tempête dans la forêt mystique",
    tags: "nature, orage, force",
    private: false,
    transcription: {
      content: "Je me trouvais au cœur d'une forêt dense pendant un orage violent. Au lieu d'avoir peur, je me sentais connectée à la puissance de la nature. Les éclairs illuminaient des sentiers secrets entre les arbres géants. La pluie sur mon visage était rafraîchissante et purifiante. J'avançais sans crainte, guidée par une force invisible. Cet orage n'était pas destructeur mais régénérateur, lavant toutes mes inquiétudes.",
      mood: "libérée",
      tag: "nature",
      rating: 8
    }
  },

  # Rêves de Lucas (Entrepreneur)
  {
    user: created_users[4],
    title: "L'entreprise qui grandit sans contrôle",
    tags: "business, croissance, perte de contrôle",
    private: true,
    transcription: {
      content: "Mon entreprise se développait à une vitesse vertigineuse, mais je perdais complètement le contrôle. De nouveaux bureaux apparaissaient partout, j'embauchais des centaines de personnes que je ne connaissais pas, et les chiffres devenaient incompréhensibles. Plus l'entreprise grandissait, plus je me sentais petit et dépassé. Ce n'était plus l'entreprise humaine que j'avais voulue créer. Je cherchais désespérément un moyen de revenir à l'essentiel.",
      mood: "dépassé",
      tag: "professionnel",
      rating: 4
    }
  },
  {
    user: created_users[4],
    title: "Méditation au sommet de la montagne",
    tags: "méditation, paix, équilibre",
    private: false,
    transcription: {
      content: "Je méditais seul au sommet d'une montagne enneigée, loin de tout le stress de l'entreprise. Le silence était parfait, l'air pur et ma respiration synchronisée avec le vent. Pour la première fois depuis des mois, je me sentais vraiment en paix. Toutes mes préoccupations professionnelles semblaient dérisoires face à l'immensité du paysage. Cette solitude n'était pas isolement mais communion avec l'essentiel.",
      mood: "serein",
      tag: "spirituel",
      rating: 10
    }
  }
]

# Création optimisée des rêves
dreams_data.each do |dream_data|
  transcription_data = dream_data.delete(:transcription)

  dream = Dream.create!(dream_data)
  transcription = dream.create_transcription!(transcription_data)

  puts "  Rêve créé : '#{dream.title}' pour #{dream.user.first_name}"

  # Génération d'analyses pour 75% des rêves
  if [true, true, true, false].sample
    begin
      analysis_content = generate_realistic_analysis(transcription)
      transcription.create_analysis!(content: analysis_content)
      puts "    Analyse IA générée"
    rescue StandardError => e
      puts "    Erreur analyse pour '#{dream.title}': #{e.message}"
    end
  end
end

# Rêves communautaires supplémentaires
puts "Création de rêves communautaires..."

community_dreams = [
  {
    user: created_users.sample,
    title: "La bibliothèque des rêves perdus",
    tags: "livres, mémoire, découverte",
    private: false,
    transcription: {
      content: "J'ai découvert une bibliothèque cachée où chaque livre contenait les rêves oubliés des gens. En ouvrant un livre au hasard, je pouvais littéralement vivre le rêve de quelqu'un d'autre. Certains étaient merveilleux, d'autres terrifiants, mais tous étaient d'une intensité incroyable. Le bibliothécaire m'a expliqué que ces rêves attendaient d'être redécouverts par leurs propriétaires. C'était magique de voir à quel point les rêves peuvent être précieux.",
      mood: "émerveillée",
      tag: "symbolique",
      rating: 8
    }
  },
  {
    user: created_users.sample,
    title: "Concert cosmique",
    tags: "musique, espace, harmonie",
    private: false,
    transcription: {
      content: "Je flottais dans l'espace et assistais à un concert donné par les planètes elles-mêmes. Chaque astre émettait une note différente, créant une symphonie cosmique d'une beauté indescriptible. Les anneaux de Saturne jouaient comme des cordes, Jupiter donnait le rythme avec ses tempêtes, et la Terre chantait une mélodie douce et familière. Cette musique des sphères me remplissait d'une paix profonde et d'un sentiment d'appartenance à l'univers.",
      mood: "transcendante",
      tag: "spirituel",
      rating: 10
    }
  }
]

community_dreams.each do |dream_data|
  transcription_data = dream_data.delete(:transcription)

  dream = Dream.create!(dream_data)
  transcription = dream.create_transcription!(transcription_data)

  puts "  Rêve communautaire créé : '#{dream.title}'"

  # Analyses garanties pour les rêves communautaires
  begin
    analysis_content = generate_realistic_analysis(transcription)
    transcription.create_analysis!(content: analysis_content)
    puts "    Analyse IA générée"
  rescue StandardError => e
    puts "    Erreur analyse : #{e.message}"
  end
end

# Statistiques finales avec mise en forme
puts "\n" + "="*60
puts "SEEDS CRÉÉS AVEC SUCCÈS"
puts "="*60
puts "Utilisateurs créés      : #{User.count}"
puts "Personnalités créées    : #{Personality.count}"
puts "Rêves créés            : #{Dream.count}"
puts "Transcriptions créées  : #{Transcription.count}"
puts "Analyses générées      : #{Analysis.count}"
puts "Rêves publics          : #{Dream.where(private: [false, nil]).count}"
puts "Rêves privés           : #{Dream.where(private: true).count}"

puts "\n" + "-"*60
puts "COMPTES DE TEST DISPONIBLES"
puts "-"*60
users_data.each do |user_data|
  email = user_data[:email]
  password = user_data[:password]
  puts "#{email} / #{password}"
end

puts "\n" + "="*60
puts "DreamLog est prêt pour les tests et démonstrations !"
puts "Connectez-vous avec un des comptes ci-dessus."
puts "="*60
