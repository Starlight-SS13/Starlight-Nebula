/obj/item/book/manual/medical_diagnostics_manual
	name = "medical diagnostics manual"
	desc = "First, do no harm. A detailed medical practitioner's guide."
	icon_state = "bookMedical"
	author = "Medical Department"
	title = "Medical Diagnostics Manual"

/obj/item/book/manual/medical_diagnostics_manual/Initialize()
	. = ..()
	var/datum/codex_entry/ailments/ailment_entry = SScodex.get_codex_entry("Medical Ailments")
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>
				<br>
				<h1>The Oath</h1>

				<i>The Medical Oath sworn by recognised medical practitioners in the employ of [global.using_map.company_name]</i><br>

				<ol>
					<li>Now, as a new doctor, I solemnly promise that I will, to the best of my ability, serve humanity-caring for the sick, promoting good health, and alleviating pain and suffering.</li>
					<li>I recognise that the practice of medicine is a privilege with which comes considerable responsibility and I will not abuse my position.</li>
					<li>I will practise medicine with integrity, humility, honesty, and compassion-working with my fellow doctors and other colleagues to meet the needs of my patients.</li>
					<li>I shall never intentionally do or administer anything to the overall harm of my patients.</li>
					<li>I will not permit considerations of gender, race, religion, political affiliation, sexual orientation, nationality, or social standing to influence my duty of care.</li>
					<li>I will oppose policies in breach of human rights and will not participate in them. I will strive to change laws that are contrary to my profession's ethics and will work towards a fairer distribution of health resources.</li>
					<li>I will assist my patients to make informed decisions that coincide with their own values and beliefs and will uphold patient confidentiality.</li>
					<li>I will recognise the limits of my knowledge and seek to maintain and increase my understanding and skills throughout my professional life. I will acknowledge and try to remedy my own mistakes and honestly assess and respond to those of others.</li>
					<li>I will seek to promote the advancement of medical knowledge through teaching and research.</li>
					<li>I make this declaration solemnly, freely, and upon my honour.</li>
				</ol><br>

				<HR COLOR="steelblue" WIDTH="60%" ALIGN="LEFT">
				<h1>Ailments</h1>
				<blockquote>[ailment_entry.lore_text]</blockquote>
				[ailment_entry.mechanics_text]
				</body>
			</html>

		"}

/obj/item/book/manual/surgical
	name = "surgery textbook"
	icon_state = "bookMedical"
	author = "Dr. Holmes MD"
	title = "Guide to Surgery"

/obj/item/book/manual/surgical/Initialize()
	. = ..()
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				h3 {font-size: 13px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>
				[SScodex.get_guide(/decl/codex_category/surgery)]
				</body>
			</html>
			"}

/obj/item/book/manual/chemistry_recipes
	name = "pharmacy textbook"
	desc = "A thick manual of chemistry, formulae and recipes useful for a chemist."
	icon_state = "bookChemistry"
	author = "Big Pharma"
	title = "Guide to Medicines & Drugs"

/obj/item/book/manual/chemistry_recipes/Initialize()
	. = ..()
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				h3 {font-size: 13px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>
				[SScodex.get_guide(/decl/codex_category/chemistry)]
				</body>
			</html>
			"}