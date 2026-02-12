-- database/schema.sql
-- SQL script to create the database and tables for the DVD collection application

-- Create the database
CREATE DATABASE my_dvdtheque CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE my_dvdtheque;

-- Table users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nom VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_email (email)
) ENGINE=InnoDB;

-- Table password_resets
CREATE TABLE password_resets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token)
) ENGINE=InnoDB;

-- Table dvds
CREATE TABLE dvds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    titre VARCHAR(255) NOT NULL,
    titre_original VARCHAR(255),
    realisateur VARCHAR(255),
    annee INT,
    duree INT,
    genre VARCHAR(100),
    nationalite VARCHAR(100),
    acteurs TEXT,
    synopsis TEXT,
    image_url VARCHAR(500),
    emplacement VARCHAR(100),
    statut ENUM('disponible', 'prêté', 'perdu') DEFAULT 'disponible',
    prete_a VARCHAR(100),
    date_pret DATE,
    notes_perso TEXT,
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_titre (titre),
    INDEX idx_statut (statut)
) ENGINE=InnoDB;

-- test data
INSERT INTO users (id, email, nom) VALUES
(1,'test@test.com', 'Test User');
(2,'soislafran@gmail.com','Leah');

INSERT INTO dvds (
  id, user_id, titre, titre_original, realisateur, annee, duree, genre, nationalite,
  acteurs, synopsis, image_url, emplacement, statut, prete_a, date_pret,
  notes_perso, date_ajout, date_modification
) VALUES
(3,2,'Le robot sauvage',NULL,'Chris Sanders',2024,90,'Animation',NULL,'Lupita Nyong\'o, Pedro Pascal','L\'adaptation du roman illustre de Peter Brown, Robot Sauvage suit l\'incroyable epopee d un robot qui apres avoir fait naufrage sur une ile desert doit apprendre a s adapter a un environnement','https://static1.tribute.ca/poster/660x980/robot-sauvage-188378.jpg','Chambre Theo, Etagere deux','en collection',NULL,NULL,'film prefere de Lea','2026-02-11 11:02:35','2026-02-11 13:29:40'),
(4,2,'Sinners',NULL,'Ryan Googler',2025,131,'Horreur',NULL,'Michael B. Jordan, Jack O\'Connell, Hailee Stenfeld, Miles Caton, Wunmi Mokasu, Jayme Lawson, Omar Miller, Delroy Lindo','Alors qu’ils cherchent à s’affranchir d’un lourd passé, deux frères jumeaux reviennent dans leur ville natale pour repartir à zéro. Mais ils comprennent qu’une puissance maléfique bien plus redoutable guette leur retour avec impatience…\n\n« À force de danser avec le diable, un beau jour, il viendra te chercher chez toi. »','https://fr.web.img2.acsta.net/img/2e/e6/2ee67debbce9b242a58e6d961acc5d83.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,'Avec des sous titres neerlandais','2026-02-11 13:48:46','2026-02-11 13:48:46'),
(5,2,'Tigresse',NULL,'Andrei Tänase',2025,76,'Drame',NULL,'Catalina Moga, Paul Ipate, Alex Velea','Suite à un signalement, Véra, vétérinaire, accueille dans son zoo une femelle tigre à laquelle elle s\'attache rapidement. Un soir, alors qu’elle vient de surprendre son mari en plein adultère, Vera, ivre de colère, omet de refermer la cage du fauve. Le lendemain, la tigresse est introuvable. La jeune femme et son mari prennent alors la tête d\'une expédition improbable pour retrouver l’animal. Plus que la quête d’un tigre en fuite, cette battue devient pour Vera une réelle introspection sur sa vie, son couple et ses aspirations.','https://fr.web.img5.acsta.net/c_310_420/img/1b/10/1b1027bce34bbe11d7a78ac565dd7a8b.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 13:52:00','2026-02-11 13:52:00'),
(6,2,'La vie de Chuck','Life of Chuck','Mike Flanagan',2024,110,'Drame',NULL,' Tom Hiddleston, Mark Hamill, Chiwetel Ejiofor, Karen Gillan','La vie extraordinaire d’un homme ordinaire racontée en trois chapitres. Merci Chuck !','https://fr.web.img6.acsta.net/c_310_420/img/99/8d/998d9c67dfd475b5c521a7a78c028361.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 13:55:10','2026-02-11 13:55:10'),
(7,2,'Aftersun',NULL,'Charlotte Wells',2023,98,'Drame',NULL,'Paul Mescal, Frankie Corio, Celia Rowlson-Hall','Avec mélancolie, Sophie se remémore les vacances d’été passées avec son père vingt ans auparavant : les moments de joie partagée, leur complicité, parfois leurs désaccords. Elle repense aussi à ce qui planait au-dessus de ces instants si précieux : la sourde et invisible menace d’un bonheur finissant. Elle tente alors de chercher parmi ces souvenirs des réponses à la question qui l’obsède depuis tant d’années : qui était réellement cet homme qu’elle a le sentiment de ne pas connaître ?','https://fr.web.img4.acsta.net/c_310_420/pictures/23/01/10/09/11/3053678.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 13:57:45','2026-02-11 13:57:45'),
(8,2,'A real pain',NULL,'Jesse Eisenberg',2025,90,'Drame',NULL,'Jesse Eisenberg, Kieran Culkin, Will Sharpe','Deux cousins aux caractères diamétralement opposés - David et Benji - se retrouvent à l’occasion d’un voyage en Pologne afin d’honorer la mémoire de leur grand-mère bien-aimée. Leur odyssée va prendre une tournure inattendue lorsque les vieilles tensions de ce duo improbable vont refaire surface avec, en toile de fond, l’histoire de leur famille…','https://fr.web.img4.acsta.net/c_310_420/img/e2/fe/e2fef695bb16493195f32c606ceaf275.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 13:58:58','2026-02-11 13:58:58'),
(9,2,'Baden Baden',NULL,'Rachel Lang',2016,61,'Comédie',NULL,'Salomé Richard, Claude Gensac, Swann Arlaud','\n\nAprès une expérience ratée sur le tournage d\'un film à l\'étranger, Ana, 26 ans, retourne à Strasbourg, sa ville natale.\n\nLe temps d\'un été caniculaire, elle se met en tête de remplacer la baignoire de sa grand-mère par une douche de plain pied, mange des petits pois carotte au ketchup, roule en Porsche, cueille des mirabelles, perd son permis, couche avec son meilleur ami et retombe dans les bras de son ex.\n\nBref, cet été là, Ana tente de se débrouiller avec la vie.\n','https://fr.web.img3.acsta.net/c_310_420/pictures/16/04/22/17/10/103672.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 14:00:22','2026-02-11 14:00:22'),
(10,2,'Le bon la brute et le cingle','좋은 놈, 나쁜 놈, 이상한 놈','Kim Jee-Woon',2008,128,'Comédie',NULL,'Song Kang-Ho, Lee Byung-Hun, Woo-Sung Jung','Mandchourie, années 30. Deux hors la loi et un chasseur de primes sont à la recherche d’une carte au trésor. À travers les dangers d\'une région en proie à de multiple conflits — l\'armée japonaise, les bandits chinois et les gangsters coréens — ils réalisent que la vraie bataille se livrera entre eux. Un seul homme en sortira vainqueur.','https://fr.web.img3.acsta.net/c_310_420/medias/nmedia/18/66/48/82/18998870.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,'version anglaise','2026-02-11 14:04:10','2026-02-11 14:04:10'),
(11,2,'Inception',NULL,'Christopher Nolan',2010,138,'Drame',NULL,'Leonardo DiCaprio, Marion Cotillard, Elliot Page, Joseph Gordon-Levitt, Tom Hardy, Cillian Murphy, Ken Wanatabe, Michael Caine','Dom Cobb est un voleur expérimenté – le meilleur qui soit dans l’art périlleux de l\'extraction : sa spécialité consiste à s’approprier les secrets les plus précieux d’un individu, enfouis au plus profond de son subconscient, pendant qu’il rêve et que son esprit est particulièrement vulnérable. Très recherché pour ses talents dans l’univers trouble de l’espionnage industriel, Cobb est aussi devenu un fugitif traqué dans le monde entier qui a perdu tout ce qui lui est cher. Mais une ultime mission pourrait lui permettre de retrouver sa vie d’avant – à condition qu’il puisse accomplir l’impossible : l’inception. Au lieu de subtiliser un rêve, Cobb et son équipe doivent faire l’inverse : implanter une idée dans l’esprit d’un individu. S’ils y parviennent, il pourrait s’agir du crime parfait. Et pourtant, aussi méthodiques et doués soient-ils, rien n’aurait pu préparer Cobb et ses partenaires à un ennemi redoutable qui semble avoir systématiquement un coup d’avance sur eux. Un ennemi dont seul Cobb aurait pu soupçonner l’existence.','https://fr.web.img6.acsta.net/c_310_420/medias/nmedia/18/72/34/14/19476654.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 14:06:30','2026-02-11 14:06:30'),
(12,2,'Interstellar',NULL,'Christopher Nolan',2014,169,'Science-Fiction',NULL,' Matthew McConaughey, Anne Hathaway, Michael Caine, Jessica Chastain','Le film raconte les aventures d’un groupe d’explorateurs qui utilisent une faille récemment découverte dans l’espace-temps afin de repousser les limites humaines et partir à la conquête des distances astronomiques dans un voyage interstellaire. ','https://fr.web.img5.acsta.net/c_310_420/pictures/14/09/24/12/08/158828.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 14:08:33','2026-02-11 14:08:33'),
(13,2,'Little Miss Sunshine',NULL,'Michael Arndt',2010,100,'Comédie',NULL,'Abigail Breslin, Greg Kinnear, Paul Dano, Toni Colette, Steve Carell','\n\nL\'histoire des Hoover. Le père, Richard, tente désespérément de vendre son \"Parcours vers le succès en 9 étapes\". La mère, Sheryl, tente de dissimuler les travers de son frère, spécialiste suicidaire de Proust fraîchement sorti de l\'hôpital après avoir été congédié par son amant.\n\nLes enfants Hoover ne sont pas non plus dépourvus de rêves improbables : la fille de 7 ans, Olive, se rêve en reine de beauté, tandis que son frère Dwayne a fait voeu de silence jusqu\'à son entrée à l\'Air Force Academy.\n\nQuand Olive décroche une invitation à concourir pour le titre très sélectif de Little Miss Sunshine en Californie, toute la famille décide de faire corps derrière elle. Les voilà donc entassés dans leur break Volkswagen rouillé : ils mettent le cap vers l\'Ouest et entament un voyage tragi-comique de trois jours qui les mettra aux prises avec des événements inattendus...\n','https://fr.web.img4.acsta.net/c_310_420/pictures/16/09/23/12/14/124206.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 14:10:02','2026-02-11 14:10:12'),
(14,2,'Ema',NULL,'Pablo Larrain',2020,107,'Thriller',NULL,'Mariana Di Girólamo, Gael García Bernal, Paola Giannini','Ema est une danseuse qui évolue au sein d\'une troupe dirigée par Gaston, un chorégraphe de renom avec qui elle est en couple. Ensemble, ils ont adopté Polo, un garçon d\'une dizaine d\'années, qu\'ils n\'ont pas su gérer et qu\'ils ont finalement rendu aux services sociaux. Depuis, l\'un et l\'autre sont rongés par la culpabilité. Ema ne supporte plus le regard qui est posé sur elle et trouve son exutoire en se déhanchant sur le reggaeton, une musique que Gaston méprise, la jugeant vulgaire. Un film stylisé sur un drame intime qui doit beaucoup à la techno envoûtante de Nicolas Jaar et à son interprète principale, Mariana Di Girolamo.','https://fr.web.img6.acsta.net/c_310_420/pictures/20/05/22/09/51/5160702.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 14:11:42','2026-02-11 14:11:42'),
(15,2,'Big Fish',NULL,'Tim Burton',2004,125,'Fantaisie',NULL,'Ewan McGregor, Helena Boham-Carter, Alison Lohman, Robert Guillaume, Marion Cotillard, Steve Buscemi, Danny Devito','L\'histoire à la fois drôle et poignante d\'Edward Bloom, un père débordant d\'imagination, et de son fils William. Ce dernier retourne au domicile familial après l\'avoir quitté longtemps auparavant, pour être au chevet de son père, atteint d\'un cancer. Il souhaite mieux le connaître et découvrir ses secrets avant qu\'il ne soit trop tard. L\'aventure débutera lorsque William tentera de discerner le vrai du faux dans les propos de son père mourant.','https://fr.web.img4.acsta.net/c_310_420/medias/nmedia/18/35/13/25/18371040.jpg','Chambre Theo, Bibliotheque droite, cinquieme rangee','en collection',NULL,NULL,NULL,'2026-02-11 14:25:00','2026-02-11 14:25:00'),
(16,2,'Philadelphia',NULL,'Jonathan Demme',1994,125,'Drame',NULL,' Tom Hanks, Denzel Washington, Mary Steenburgen','Andrew Beckett, un jeune et brillant avocat qui travaille dans un grand cabinet, se voit confier une affaire très importante. Mais son licenciement brutal suit de peu cette consécration. Homosexuel et séropositif, Andrew se doute bien des raisons. Il entame un long procès pour dénoncer cette discrimination…','https://fr.web.img6.acsta.net/c_310_420/pictures/22/05/09/09/01/5332995.jpg','Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,'2026-02-11 14:59:35','2026-02-11 14:59:35'),
(17,2,'Voyage de Chihiro','Sen to Chihiro','Hayao Miyazaki',2002,125,'Animation',NULL,' Rumi Hiiragi, Miyu Irino, Mari Natsuki','Chihiro, une fillette de 10 ans, est en route vers sa nouvelle demeure en compagnie de ses parents. Au cours du voyage, la famille fait une halte dans un parc à thème qui leur paraît délabré. Lors de la visite, les parents s’arrêtent dans un des bâtiments pour déguster quelques mets très appétissants, apparus comme par enchantement. Hélas cette nourriture les transforme en porcs. Prise de panique, Chihiro s’enfuit et se retrouve seule dans cet univers fantasmagorique ; elle rencontre alors l’énigmatique Haku, son seul allié dans cette terrible épreuve...','https://fr.web.img5.acsta.net/c_310_420/medias/nmedia/00/02/36/71/chihiro.jpg','Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,'2026-02-11 15:00:55','2026-02-11 15:00:55'),
(18,2,'marry poppins',NULL,NULL,NULL,NULL,'Comédie',NULL,'Julie Andrews, Dick Van Dyke, David Tomlinson','Rien ne va plus dans la famille Banks. La nurse vient de donner ses huit jours. Et ni M. Banks, banquier d\'affaire, ni son épouse, suffragette active, ne peuvent s\'occuper des enfants Jane et Michaël. Ces derniers passent alors une annonce tout à fait fantaisiste pour trouver une nouvelle nurse. C\'est Mary Poppins qui répond et apparaît dès le lendemain, portée par le vent d\'Est. Elle entraîne aussitôt les enfants dans son univers merveilleux. Un des plus célèbres films de la production Disney.','https://fr.web.img6.acsta.net/c_310_420/medias/nmedia/00/02/52/16/mary.jpg','Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,'2026-02-11 15:10:44','2026-02-11 15:10:44');
(19,2,'Drive',NULL,'Nicolas Winding Refn',2011,100,'Thriller',NULL,'Ryan Gosling, Carey Mulligan, Bryan Cranston','Un cascadeur hollywoodien devient chauffeur pour des braqueurs la nuit. Sa vie bascule lorsqu il tente d aider sa voisine et son fils.', NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(20,2,'The Dark Knight',NULL,'Christopher Nolan',2008,152,'Action',NULL, 'Christian Bale, Heath Ledger, Aaron Eckhart', 'Batman affronte le Joker, un criminel anarchiste qui plonge Gotham dans le chaos.', NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(21,2,'Sicario',NULL,'Denis Villeneuve',2015,121,'Thriller',NULL, 'Emily Blunt, Benicio Del Toro, Josh Brolin','Une agente du FBI est recrutée pour une opération secrète contre un cartel mexicain.', NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(22,2,'Mulholland Drive',NULL,'David Lynch',2001,147,'Mystere',NULL, 'Naomi Watts, Laura Harring, Justin Theroux','Une jeune actrice arrive a Los Angeles et se retrouve impliquée dans une énigme troublante.', NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(23,2,'La Cité de Dieu','Cidade de Deus','Fernando Meirelles',2002,130,'Drame',NULL, 'Alexandre Rodrigues, Leandro Firmino', 'L ascension violente du crime organisé dans une favela de Rio de Janeiro.', NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(24,2,'Requiem for a Dream',NULL,'Darren Aronofsky',2000,102,'Drame',NULL, 'Ellen Burstyn, Jared Leto, Jennifer Connelly', 'Quatre destins liés par l addiction et la destruction progressive de leurs rêves.', NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(25,2,'The Grand Budapest Hotel',NULL,'Wes Anderson',2014,99,'Comédie',NULL, 'Ralph Fiennes, Tony Revolori, Saoirse Ronan', 'Les aventures extravagantes d un concierge d hôtel en Europe centrale.', NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(26,2,'Anatomie d une chute',NULL,'Justine Triet',2023,150,'Drame',NULL, 'Sandra Huller, Swann Arlaud', 'Une femme est accusée du meurtre de son mari après sa chute mystérieuse.', NULL,'Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,NOW(),NOW()),
(27,2,'Only God Forgives',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(28,2,'Lost River',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(29,2,'The Neon Demon',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(30,2,'Memento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(31,2,'Sound of Metal',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(32,2,'Insomnia',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(33,2,'Bienvenue à Suburbicon',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(34,2,'Passion',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(35,2,'Soyez sympas, rembobinez',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(36,2,'Asteroid City',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere du haut','en collection',NULL,NULL,NULL,NOW(),NOW()),
(37,2,'John Wick',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,NOW(),NOW()),
(38,2,'Stalker',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,NOW(),NOW()),
(39,2,'Dans les forêts de Sibérie',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,NOW(),NOW()),
(40,2,'Chernobyl',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Leah, bibliotheque 1','en collection',NULL,NULL,NULL,NOW(),NOW()),
(41,2,'Coco',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(42,2,'Brokeback Mountain',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(43,2,'Red Lights',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(44,2,'Watchmen',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(45,2,'28 jours plus tard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(46,2,'28 semaines plus tard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(47,2,'Seul dans Berlin',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(48,2,'Jeune & Jolie',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(49,2,'Neruda',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(50,2,'Babylon',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(51,2,'Past Lives',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW()),
(52,2,'Dark Waters',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Chambre Theo, Etagere deux','en collection',NULL,NULL,NULL,NOW(),NOW());