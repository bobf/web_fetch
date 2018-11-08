FROM library/ruby
ADD .build/web_fetch.tar.gz .
WORKDIR web_fetch
RUN bundle && bundle exec rake install
CMD ["web_fetch_control", "run", "--", "--port", "8077", "--host", "0.0.0.0"]
