# frozen_string_literal: true

RSpec.describe GraphQL::Searchkick::ResultConnection, search: true do
  let(:query_string) do
    <<-GQL
      query getProjects(
        $first: Int,
        $last: Int,
        $before: String,
        $after: String,
      ) {
        projects(
          first: $first,
          last: $last,
          before: $before,
          after: $after
        ) {
          pageInfo {
            hasPreviousPage
            hasNextPage
            startCursor
            endCursor
          }
          edges {
            node {
              id
              name
              createdAt
            }
          }
        }
      }
    GQL
  end
  let(:first) { 100 }
  let(:last) { nil }
  let(:before) { nil }
  let(:after) { nil }
  let(:variables) do
    {
      first: first,
      last: last,
      before: before,
      after: after
    }
  end
  let(:search_query) { '*' }

  before(:all) do
    20.times do |n|
      Project.create!(id: n, name: "Test Project #{n}")
    end

    Project.reindex
  end

  subject { execute_query(query_string, variables: variables) }

  describe 'pagination' do
    describe 'after' do
      describe 'is nil' do
        it 'does not apply an offset' do
          cursor = subject.dig(:data, :projects, :pageInfo, :startCursor)
          expect(cursor).to eq(encode_cursor(1))
        end
      end

      describe 'is present' do
        let(:after) { encode_cursor(5) }

        it 'applies an offset' do
          cursor = subject.dig(:data, :projects, :pageInfo, :startCursor)
          expect(cursor).to eq(encode_cursor(6))
        end

        describe 'before is present' do
          describe 'after is < before' do
            let(:before) { encode_cursor(10) }

            it 'sets the limit to before - after - 1' do
              start_cursor = subject.dig(:data, :projects, :pageInfo, :startCursor)
              end_cursor = subject.dig(:data, :projects, :pageInfo, :endCursor)
              expect(start_cursor).to eq(encode_cursor(6))
              expect(end_cursor).to eq(encode_cursor(9))
            end
          end

          describe 'after is >= before' do
            let(:before) { encode_cursor(4) }

            it 'sets the limit to 0' do
              start_cursor = subject.dig(:data, :projects, :pageInfo, :startCursor)
              end_cursor = subject.dig(:data, :projects, :pageInfo, :endCursor)
              expect(start_cursor).to eq(nil)
              expect(end_cursor).to eq(nil)
            end
          end
        end

      end
    end

    describe 'before' do
      describe 'is present' do
        let(:before) { encode_cursor(10) }

        it 'applies a limit' do
          start_cursor = subject.dig(:data, :projects, :pageInfo, :startCursor)
          end_cursor = subject.dig(:data, :projects, :pageInfo, :endCursor)
          expect(start_cursor).to eq(encode_cursor(1))
          expect(end_cursor).to eq(encode_cursor(9))
        end
      end
    end

    describe 'first' do
      describe 'is nil' do
        it 'sets limit to max_page_size' do
          cursor = subject.dig(:data, :projects, :pageInfo, :endCursor)
          expect(cursor).to eq(encode_cursor(20))
        end
      end

      describe 'is present' do
        let(:first) { 5 }

        it 'applies a limit' do
          start_cursor = subject.dig(:data, :projects, :pageInfo, :startCursor)
          end_cursor = subject.dig(:data, :projects, :pageInfo, :endCursor)
          expect(start_cursor).to eq(encode_cursor(1))
          expect(end_cursor).to eq(encode_cursor(5))
        end
      end
    end

    describe 'last' do
      describe 'is present' do
        let(:last) { 5 }

        describe 'a limit has been applied' do
          describe 'that is > last' do
            let(:first) { 20 }

            it 'sets the offset to limit - last' do
              start_cursor = subject.dig(:data, :projects, :pageInfo, :startCursor)
              end_cursor = subject.dig(:data, :projects, :pageInfo, :endCursor)
              expect(start_cursor).to eq(encode_cursor(16))
              expect(end_cursor).to eq(encode_cursor(20))
            end
          end
        end
      end
    end
  end

  describe 'page_info' do

    describe '#has_next_page' do

      describe 'when there is a next page' do

        describe 'first is nil' do
          it 'returns false' do
            has_next = subject.dig(:data, :projects, :pageInfo, :hasNextPage)
            expect(has_next).to eq(false)
          end
        end

        describe 'after' do
          let(:first) { 10 }
          describe 'is within bounds' do
            let(:after) { encode_cursor(5) }

            it 'returns true' do
              has_next = subject.dig(:data, :projects, :pageInfo, :hasNextPage)
              expect(has_next).to eq(true)
            end
          end

          describe 'is out of bounds' do
            let(:after) { encode_cursor(200) }

            it 'returns false' do
              has_next = subject.dig(:data, :projects, :pageInfo, :hasNextPage)
              expect(has_next).to eq(false)
            end
          end
        end
      end

      describe 'when there is not a next page' do
        let(:first) { 20 }

        it 'returns false' do
          has_next = subject.dig(:data, :projects, :pageInfo, :hasNextPage)
          expect(has_next).to eq(false)
        end
      end

    end

    describe '#has_previous_page' do
      let(:first) { nil }

      describe 'when there is a previous page' do
        describe 'last' do

          describe 'is nil' do
            it 'returns false' do
              has_prev = subject.dig(:data, :projects, :pageInfo, :hasPreviousPage)
              expect(has_prev).to eq(false)
            end
          end

          describe 'is within bounds' do
            let(:last) { 10 }
            it 'returns true' do
              has_prev = subject.dig(:data, :projects, :pageInfo, :hasPreviousPage)
              expect(has_prev).to eq(true)
            end
          end

          describe 'is out of bounds' do
            let(:last) { 20 }
            it 'returns false' do
              has_prev = subject.dig(:data, :projects, :pageInfo, :hasPreviousPage)
              expect(has_prev).to eq(false)
            end
          end

        end
      end

    end

    describe '#start_cursor' do
      describe 'there are results' do
        it 'returns the cursor for the first record' do
          cursor = subject.dig(:data, :projects, :pageInfo, :startCursor)
          expect(cursor).to eq(encode_cursor(1))
        end
      end

      describe 'there are no results' do
        let(:first) { 21 }

        it 'returns 1' do
          cursor = subject.dig(:data, :projects, :pageInfo, :startCursor)
          expect(cursor).to eq(encode_cursor(1))
        end
      end
    end

    describe '#end_cursor' do
      describe 'there are results' do
        it 'returns the cursor for the last record' do
          cursor = subject.dig(:data, :projects, :pageInfo, :endCursor)
          expect(cursor).to eq(encode_cursor(20))
        end
      end

      describe 'there are no results' do
        let(:first) { 21 }

        it 'returns the last cursor for the set' do
          cursor = subject.dig(:data, :projects, :pageInfo, :endCursor)
          expect(cursor).to eq(encode_cursor(20))
        end
      end
    end
  end

end
