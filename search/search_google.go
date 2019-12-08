package mediasearch

import (
	"fmt"
	"log"
	"strings"

	"net/http"
	"net/url"
	"regexp"
)

var imdbIDRe = regexp.MustCompile(`\/(tt\d+)\/`)

//uses im feeling lucky and grabs the "Location"
//header from the 302, which contains the IMDB ID
func searchGoogle(query, year string, mediatype MediaType) ([]Result, error) {

	if year != "" {
		query += " " + year
	}
	if string(mediatype) != "" {
		query += " " + string(mediatype)
	}
	query += " site:imdb.com"
	if debugMode {
		log.Printf("Searching Google for '%s'", query)
	}
	v := url.Values{}
	v.Set("btnI", "") //I'm feeling lucky
	v.Set("q", query)
	urlstr := "https://www.google.com/search?" + v.Encode()
	req, err := http.NewRequest("HEAD", urlstr, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "*/*")
	//I'm a browser... :)
	req.Header.Set("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) "+
		"AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36")
	//roundtripper doesn't follow redirects
	resp, err := http.DefaultTransport.RoundTrip(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	//assume redirection
	if resp.StatusCode != 302 {
		return nil, fmt.Errorf("Google search failed with StatusCode=%d", resp.StatusCode)
	}
	//extract Location header URL
	imdb, _ := url.Parse(resp.Header.Get("Location"))
	if imdb.Host != "www.imdb.com" {
		query, _ := url.ParseQuery(imdb.RawQuery)
		q := query["q"][0]
		if strings.Contains(q, "www.imdb.com") {
			imdb, _ = url.Parse(q)
		} else {
			return nil, fmt.Errorf("Google IMDB redirection failed with Host=%s", imdb.Host)
		}
	}
	//extract imdb ID
	m := imdbIDRe.FindStringSubmatch(imdb.Path)
	if len(m) == 0 {
		return nil, fmt.Errorf("No IMDB match (%s)", imdb.Path)
	}
	//lookup imdb ID using OMDB
	r, err := imdbGet(imdbID(m[1]))
	if err != nil {
		return nil, err
	}
	return []Result{r}, nil
}
