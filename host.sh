echo 'Building postgresql'

sudo apt-get update
sudo apt-get install git build-essential gettext
sudo apt-get install libreadline6 libreadline6-dev
sudo apt-get install zlib1g-dev
sudo apt-get install flex
git clone git@github.com:postgres/postgres.git

cd postgres
./configure
make
sudo make install

export PATH=$PATH:/usr/local/pgsql/bin

cd ..
mkdir data
export PGDATA=`pwd`/data

initdb

echo "host    all             all             0.0.0.0/0            trust" >> `pwd`/data/pg_hba.conf
pg_ctl -D `pwd`/data/ -o "-p 5455" -l pg.log start
