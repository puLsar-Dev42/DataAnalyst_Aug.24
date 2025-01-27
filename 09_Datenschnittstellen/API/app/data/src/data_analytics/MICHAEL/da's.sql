SELECT p.planet_id,
	   p.planet_name,
	   p.planet_type,
	   v.orbital_period_days,
	   v.mass_wrt,
	   v.mass_multiplier,
	   s.star_id,
	   s.host_star_name,
	   v.spectral_type
FROM values AS v
		 JOIN
	 stars AS s
	 ON
		 v.star_id = s.star_id
		 JOIN planets AS p ON v.planet_id = p.planet_id
WHERE v.orbital_period_days IS NOT NULL
  AND v.spectral_type IS NOT NULL
  AND p.planet_type = 'Terrestrial'
  AND v.mass_wrt = 'Earth';



SELECT s.star_id,
	   s.host_star_name,
	   s.spectral_type,
	   p.planet_id,
	   s.planet_name,
	   p.planet_type
FROM stars AS s
		 JOIN public.planets AS p ON s.planet_name = p.planet_name
WHERE planet_type = ''